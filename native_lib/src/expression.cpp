#include "circuit_solver/expression.h"

#include <cassert>
#include <cstddef>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <unordered_set>
#include <vector>

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

Expression::Expression() : Expression(std::make_shared<VariableNode>()) {}

Expression::Expression(const Expression& other) = default;

auto Expression::operator=(const Expression& other) -> Expression& = default;

Expression::Expression(double value)
    : Expression(std::make_shared<VariableNode>(value)) {}

Expression::Expression(std::shared_ptr<ExpressionNode> root)
    : root(std::move(root)) {}

Expression::~Expression() = default;

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
      return Expression(root);
    }
  }

  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    if (v->value == 0) {
      return {root};
    }
    if (v->value == 1) {
      return Expression(std::move(rhs.root));
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

auto std::exp(Expression arg) -> Expression {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(arg.root);
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

auto Expression::operator<(Expression rhs) const -> Condition {
  return {root, std::move(rhs.root), BooleanBinaryOp::LT};
}

auto Expression::operator<=(Expression rhs) const -> Condition {
  return {root, std::move(rhs.root), BooleanBinaryOp::LEQ};
}
auto Expression::operator>(Expression rhs) const -> Condition {
  return {root, std::move(rhs.root), BooleanBinaryOp::GT};
}
auto Expression::operator>=(Expression rhs) const -> Condition {
  return {root, std::move(rhs.root), BooleanBinaryOp::GEQ};
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

auto Expression::getUnknowns() const -> const std::vector<double*>& {
  if (unknowns == nullptr) {
    updateMapAndUnknowns();
  }
  return *unknowns;
}

auto Expression::getMutableUnknowns() -> std::vector<double*> {
  if (unknowns == nullptr) {
    updateMapAndUnknowns();
  }
  return *unknowns;
}

void Expression::updateMapAndUnknowns() const {
  map = std::make_shared<ExpressionMap>();
  unknowns = std::make_shared<std::vector<double*>>();

  std::unordered_set<double*> unknown_set;
  root->getUnknowns(unknown_set);

  unknowns->reserve(unknown_set.size());
  unsigned i = 0;
  for (double* unknown : unknown_set) {
    unknowns->push_back(unknown);
    (*map)[unknown] = i;
    i++;
  }
}

auto Expression::getDiscontinuities() -> std::unordered_set<double*> {
  std::unordered_set<double*> discontinuities;
  root->getDiscontinuities(discontinuities);
  return discontinuities;
}

auto Expression::getDiscontinuityErrors() -> std::vector<Expression> {
  std::vector<ExpressionNodePtr> errors;
  std::vector<Expression> errorExpressions;
  root->getDiscontinuityError(errors);
  errorExpressions.reserve(errors.size());
  for (const auto& error : errors) {
    errorExpressions.push_back(Expression(error));
  }
  return errorExpressions;
}

auto Expression::getNumUnknowns() const -> size_t {
  return getUnknowns().size();
}

auto Expression::getMap() const -> const ExpressionMap& {
  if (map == nullptr) {
    updateMapAndUnknowns();
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

void Expression::addToProblem(ceres::Problem& problem) {
  if (map == nullptr) {
    updateMapAndUnknowns();
  }
  auto* costFunctor = new ExpressionCostFunctor(root, *map);
  auto* costFunction =
      new ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>(
          costFunctor);
  for (size_t i = 0; i < unknowns->size(); i++) {
    costFunction->AddParameterBlock(1);
  }
  auto discontinuityErrors = getDiscontinuityErrors();
  for (auto error : discontinuityErrors) {
    error.addToProblem(problem);
  }
  costFunction->SetNumResiduals(1);
  problem.AddResidualBlock(costFunction, new ceres::HuberLoss(2.0), *unknowns);
}

auto Expression::evaluate() const -> double {
  auto* parameters = new double[getNumUnknowns()];
  ExpressionMap map = getMap();
  return expressionNode::evaluate(root, parameters, map);
}

auto Expression::evaluate(double const* parameters) const -> double {
  ExpressionMap map = getMap();
  return expressionNode::evaluate(root, parameters, map);
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
  options.function_tolerance = 1e-6;
  options.gradient_tolerance = 0;   // 1e-6
  options.parameter_tolerance = 0;  // 1e-6
  options.max_num_iterations = 1000;
  // options.min_trust_region_radius = 1e-64;
  // NOTE: this parameter is VERY important - results in ~1500x better
  // performance
  options.use_nonmonotonic_steps = true;
  options.max_consecutive_nonmonotonic_steps = 10;
  return options;
}
