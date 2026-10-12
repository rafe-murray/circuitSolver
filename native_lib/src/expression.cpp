#include "circuit_solver/expression.h"

#include <ceres/dynamic_autodiff_cost_function.h>
#include <ceres/loss_function.h>
#include <ceres/problem.h>
#include <ceres/solver.h>
#include <ceres/types.h>

#include <cassert>
#include <cmath>
#include <cstddef>
#include <iostream>
#include <memory>
#include <span>
#include <stdexcept>
#include <unordered_set>
#include <utility>
#include <vector>

#include "circuit_solver/config.h"
#include "circuit_solver/expressionCostFunctor.h"
#include "circuit_solver/expressionNode.h"

// TODO: add a scaling factor for each Expression
// - This way parameters can on the order of 1, which ceres expects
// - Still have accurate calculations
// - Apply the scaling factor when evaluating the Expression given a list of
// `double` parameters
// - We'd apply this manually given what type of answer we expect:
//  - 0.001 for resistors
//  - 1000 for currents
//  - 1 for voltages
//  - 1 by default

using circuitsolver::constants::functionTolerance;
using circuitsolver::constants::huberLossDelta;
using circuitsolver::constants::maxConsecutiveNonMonotonicSteps;
using circuitsolver::constants::maxIterations;

Expression::Expression() : Expression(std::make_shared<VariableNode>()) {}

Expression::Expression(double value)
    : Expression(std::make_shared<VariableNode>(value)) {}

Expression::Expression(std::shared_ptr<ExpressionNode> root)
    : root(std::move(root)) {}

auto Expression::operator+(Expression rhs) const -> Expression {
  std::shared_ptr<VariableNode> u =
      std::dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 0) {
    return {root};
  }

  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known && v->value == 0) {
    return {std::move(rhs.root)};
  }

  if (v && u && v->known && u->known) {
    return {u->value + v->value};
  }

  std::shared_ptr<UnaryOpNode> n =
      std::dynamic_pointer_cast<UnaryOpNode>(rhs.root);
  if (n && n->op == UnaryOp::NEG) {
    return {std::make_shared<BinaryOpNode>(root, n->operand, BinaryOp::SUB)};
  }

  return {
      std::make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::ADD)};
}

auto Expression::operator-(Expression rhs) const -> Expression {
  std::shared_ptr<VariableNode> u =
      std::dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 0) {
    return {root};
  }

  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known && v->value == 0) {
    if (u && u->known) {
      return {-u->value};
    }
    return -Expression(std::move(rhs.root));
  }

  if (v && u && v->known && u->known) {
    return {v->value - u->value};
  }

  if (root == rhs.root) {
    return {0.0};
  }

  return {
      std::make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::SUB)};
}

auto Expression::operator*(Expression rhs) const -> Expression {
  std::shared_ptr<VariableNode> u =
      std::dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known) {
    if (u->value == 0) {
      return {std::move(rhs.root)};
    }
    if (u->value == 1) {
      return {root};
    }
  }

  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    if (v->value == 0) {
      return {root};
    }
    if (v->value == 1) {
      return {std::move(rhs.root)};
    }
  }

  if (v && u && v->known && u->known) {
    return {u->value * v->value};
  }

  return {
      std::make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::MUL)};
}

auto Expression::operator/(Expression rhs) const -> Expression {
  std::shared_ptr<VariableNode> u =
      std::dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 1) {
    return {root};
  }

  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);

  if (v && u && v->known && u->known) {
    return {v->value / u->value};
  }

  if (root == rhs.root) {
    return {1.0};
  }

  return {
      std::make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::DIV)};
}

auto Expression::operator-() const -> Expression {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    return {-v->value};
  }
  return {std::make_shared<UnaryOpNode>(root, UnaryOp::NEG)};
}

auto circuitsolver::expression::exp(Expression arg) -> Expression {
  std::shared_ptr<VariableNode> v =
      dynamic_pointer_cast<VariableNode>(arg.root);
  if (v && v->known) {
    return {std::exp(v->value)};
  }
  return {make_shared<UnaryOpNode>(std::move(arg.root), UnaryOp::EXP)};
}

auto Expression::operator==(const Expression& rhs) const -> bool {
  std::shared_ptr<VariableNode> u =
      std::dynamic_pointer_cast<VariableNode>(root);
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(rhs.root);
  // TODO: why has this been implemented this way?
  if (u && v && u->known && v->known) {
    return u->value == v->value;
  }
  return root == rhs.root;
}

auto Expression::operator==(double rhs) const -> bool {
  if (!isConstant()) {
    return false;
  }
  return evaluate() == rhs;
}

auto Expression::operator!=(const Expression& rhs) const -> bool {
  return !(*this == rhs);
}

auto Expression::operator=(double rhs) -> Expression& {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v) {
    v->value = rhs;
    v->known = true;
  } else {
    {
      throw std::invalid_argument(
          "Attempting to assign to an Expression that is "
          "dependent on multiple unknowns");
    }
  }
  return *this;
}

auto Expression::operator+=(const Expression& rhs) -> Expression& {
  *this = *this + rhs;
  return *this;
}

auto Expression::operator-=(const Expression& rhs) -> Expression& {
  *this = *this - rhs;
  return *this;
}

auto Expression::operator<(const Expression& rhs) const -> Condition {
  return {root, rhs.root, BooleanBinaryOp::LT};
}

auto Expression::operator<=(const Expression& rhs) const -> Condition {
  return {root, rhs.root, BooleanBinaryOp::LEQ};
}
auto Expression::operator>(const Expression& rhs) const -> Condition {
  return {root, rhs.root, BooleanBinaryOp::GT};
}
auto Expression::operator>=(const Expression& rhs) const -> Condition {
  return {root, rhs.root, BooleanBinaryOp::GEQ};
}
// Condition Expression::operator!=(Expression rhs) const {
//   return Condition(root, std::move(rhs.root), BooleanBinaryOp::NEQ);
// }
// Condition Expression::equals(Expression rhs) const {
//   return Condition(root, std::move(rhs.root), BooleanBinaryOp::EQ);
// }
auto Expression::makeConditional(const Condition& condition,
                                 Expression valIfTrue, Expression valIfFalse)
    -> Expression {
  return {std::make_shared<TernaryOpNode>(
      std::make_shared<Condition>(condition), std::move(valIfTrue.root),
      std::move(valIfFalse.root))};
}

auto Expression::isConstant() const -> bool {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  return v && v->known;
}

// auto Expression::getUnknowns() const -> const std::vector<double*>& {
//   if (unknowns == nullptr) {
//     updateMapAndUnknowns();
//   }
//   return *unknowns;
// }

void Expression::setConditionMap(const ConditionMap& conditionMap) {
  this->conditionMap = std::make_shared<ConditionMap>(conditionMap);
}

auto Expression::getUnknowns() -> std::vector<double*> {
  if (unknowns == nullptr) {
    updateInternalState();
  }
  return *unknowns;
}

void Expression::updateInternalState() const {
  map = std::make_shared<ExpressionMap>();
  unknowns = std::make_shared<std::vector<double*>>();

  std::unordered_set<double*> unknown_set;
  root->getUnknowns(unknown_set);

  unknowns->reserve(unknown_set.size());
  unsigned i = 0;
  // Sorting algorithm is already non-deterministic
  // NOLINTBEGIN(bugprone-nondeterministic-pointer-iteration-order)
  for (auto* unknown : unknown_set) {
    unknowns->push_back(unknown);
    (*map)[unknown] = i;
    i++;
  }
  // NOLINTEND(bugprone-nondeterministic-pointer-iteration-order)
}

auto Expression::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  return root->getConditions();
}

auto Expression::getNumUnknowns() const -> size_t {
  if (unknowns == nullptr) {
    updateInternalState();
  }
  return unknowns->size();
}

auto Expression::getMap() const -> const ExpressionMap& {
  if (map == nullptr) {
    updateInternalState();
  }
  return *map;
}

// ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>*
// Expression::getCostFunction() {
//   ExpressionMap map = getMap();
//   auto costFunctor = new ExpressionCostFunctor(root, map);
//   return new ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>(
//       costFunctor);
// }

void Expression::addToProblem(ceres::Problem& problem) const {
  addToProblem(problem, defaultConditionMap());
}

void Expression::addToProblem(ceres::Problem& problem,
                              const ConditionMap& conditionMap) const {
  if (map == nullptr) {
    updateInternalState();
  }
  // Ceres takes ownership
  // NOLINTBEGIN(cppcoreguidelines-owning-memory)
  auto* costFunctor = new ExpressionCostFunctor(root, *map, conditionMap);
  auto* costFunction =
      new ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>(
          costFunctor);
  // NOLINTEND(cppcoreguidelines-owning-memory)

  for (size_t i = 0; i < unknowns->size(); i++) {
    costFunction->AddParameterBlock(1);
  }
  // for (int i = 0; i < numDiscontinuities; i++) {
  // problem.SetParameterLowerBound(unknowns, i, val)
  // }
  // auto discontinuityErrors = getDiscontinuityErrors();
  // for (auto error : discontinuityErrors) {
  //   error.addToProblem(problem);
  // }
  costFunction->SetNumResiduals(1);

  // NOLINTBEGIN(cppcoreguidelines-owning-memory)
  // Ceres takes ownership
  problem.AddResidualBlock(costFunction, new ceres::HuberLoss(huberLossDelta),
                           *unknowns);
  // NOLINTEND(cppcoreguidelines-owning-memory)
}
auto Expression::defaultConditionMap() const -> ConditionMap {
  auto cm = ConditionMap{};
  auto conditions = getConditions();
  for (const auto& condition : conditions) {
    cm[condition] = false;
  }
  return cm;
}

auto Expression::evaluate() const -> double {
  auto parameters = std::vector<double>(getNumUnknowns());
  ExpressionMap map = getMap();
  if (conditionMap == nullptr) {
    conditionMap = std::make_shared<ConditionMap>(defaultConditionMap());
  }
  return expressionNode::evaluate(root, std::span<const double>{parameters},
                                  map, *conditionMap);
}

auto Expression::evaluate(std::span<const double> parameters) const -> double {
  ExpressionMap map = getMap();
  if (conditionMap == nullptr) {
    conditionMap = std::make_shared<ConditionMap>(defaultConditionMap());
  }
  return expressionNode::evaluate(root, parameters, map, *conditionMap);
}

auto Expression::getPtrToUnknown() -> double* {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v) {
    return &v->value;
  }
  return nullptr;
}

void Expression::markKnown() { root->markKnown(); }

auto operator<<(std::ostream& out, const Expression& e) -> std::ostream& {
  out << "(" << e.root.get() << ")" << e.root;
  return out;
}

auto getDefaultOptions() -> ceres::Solver::Options {
  ceres::Solver::Options options;

  options.linear_solver_type = ceres::DENSE_QR;
  options.minimizer_type = ceres::TRUST_REGION;
  options.trust_region_strategy_type = ceres::LEVENBERG_MARQUARDT;
  options.function_tolerance = functionTolerance;
  options.gradient_tolerance = 0;   // 1e-6
  options.parameter_tolerance = 0;  // 1e-6
  options.max_num_iterations = maxIterations;
  // options.min_trust_region_radius = 1e-64;
  // NOTE: this parameter is VERY important - results in ~1500x better
  // performance
  options.use_nonmonotonic_steps = true;
  options.max_consecutive_nonmonotonic_steps = maxConsecutiveNonMonotonicSteps;
  return options;
}
