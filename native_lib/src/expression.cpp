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
#include <map>
#include <memory>
#include <optional>
#include <span>
#include <stdexcept>
#include <tuple>
#include <unordered_map>
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

namespace circuitsolver::expression {
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
  if (n && n->op == UnaryOpNode::Op::NEG) {
    return {std::make_shared<BinaryOpNode>(root, n->operand,
                                           BinaryOpNode::Op::SUB)};
  }

  return {std::make_shared<BinaryOpNode>(root, std::move(rhs.root),
                                         BinaryOpNode::Op::ADD)};
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

  return {std::make_shared<BinaryOpNode>(root, std::move(rhs.root),
                                         BinaryOpNode::Op::SUB)};
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

  return {std::make_shared<BinaryOpNode>(root, std::move(rhs.root),
                                         BinaryOpNode::Op::MUL)};
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

  return {std::make_shared<BinaryOpNode>(root, std::move(rhs.root),
                                         BinaryOpNode::Op::DIV)};
}

auto Expression::operator-() const -> Expression {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    return {-v->value};
  }
  return {std::make_shared<UnaryOpNode>(root, UnaryOpNode::Op::NEG)};
}

auto exp(Expression arg) -> Expression {
  std::shared_ptr<VariableNode> v =
      dynamic_pointer_cast<VariableNode>(arg.root);
  if (v && v->known) {
    return {std::exp(v->value)};
  }
  return {make_shared<UnaryOpNode>(std::move(arg.root), UnaryOpNode::Op::EXP)};
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
  return {root, rhs.root, Condition::Op::LT};
}

auto Expression::operator<=(const Expression& rhs) const -> Condition {
  return {root, rhs.root, Condition::Op::LEQ};
}
auto Expression::operator>(const Expression& rhs) const -> Condition {
  return {root, rhs.root, Condition::Op::GT};
}
auto Expression::operator>=(const Expression& rhs) const -> Condition {
  return {root, rhs.root, Condition::Op::GEQ};
}
// Condition Expression::operator!=(Expression rhs) const {
//   return Condition(root, std::move(rhs.root), Condition::Op::NEQ);
// }
// Condition Expression::equals(Expression rhs) const {
//   return Condition(root, std::move(rhs.root), Condition::Op::EQ);
// }
auto Expression::makeConditional(const Condition& condition,
                                 Expression valIfTrue, Expression valIfFalse)
    -> Expression {
  return {std::make_shared<TernaryOpNode>(
      std::make_shared<Condition>(condition), std::move(valIfTrue.root),
      std::move(valIfFalse.root))};
}

namespace {
auto nodeIsConstant(const ExpressionNodePtr& node) -> bool {
  if (node->kind() == ExpressionNode::Kind::Variable) {
    auto variable = std::static_pointer_cast<VariableNode>(node);
    if (variable->known) {
      return true;
    }
  }
  return false;
}
}  // namespace

auto Expression::isConstant() const -> bool { return nodeIsConstant(root); }

auto Expression::isLinear(const ConditionMap& conditionMap) const -> bool {
  return circuitsolver::expression::isLinear({*this}, conditionMap);
}

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

  std::unordered_set<double*> unknownSet{};
  for (const auto& node : nodes()) {
    if (node->kind() == ExpressionNode::Kind::Variable) {
      auto variable = std::static_pointer_cast<VariableNode>(node);
      if (!variable->known) {
        unknownSet.insert(&variable->value);
      }
    }
  }

  unknowns->reserve(unknownSet.size());
  unsigned i = 0;
  // Sorting algorithm is already non-deterministic
  // NOLINTBEGIN(bugprone-nondeterministic-pointer-iteration-order)
  for (auto* unknown : unknownSet) {
    unknowns->push_back(unknown);
    (*map)[unknown] = i;
    i++;
  }
  // NOLINTEND(bugprone-nondeterministic-pointer-iteration-order)
}

auto Expression::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  auto conditions = std::unordered_set<std::shared_ptr<const Condition>>{};
  for (const auto& node : nodes()) {
    if (node->kind() == ExpressionNode::Kind::TernaryOp) {
      auto ternOp = std::static_pointer_cast<TernaryOpNode>(node);
      conditions.insert(ternOp->condition);
    }
  }
  return conditions;
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
  costFunction->SetNumResiduals(1);

  // NOLINTBEGIN(cppcoreguidelines-owning-memory)
  // Ceres takes ownership
  problem.AddResidualBlock(costFunction, new ceres::HuberLoss(huberLossDelta),
                           *unknowns);
  // NOLINTEND(cppcoreguidelines-owning-memory)
}

void Expression::addConditionToProblem(
    ceres::Problem& problem, const std::shared_ptr<const Condition>& condition,
    const ConditionMap& conditionMap) {
  Expression{condition->getError()}.addToProblem(problem, conditionMap);
  double* constraint = condition->getConstraint();
  if (conditionMap.at(condition)) {
    problem.SetParameterLowerBound(constraint, 0, 0.0);
  } else {
    problem.SetParameterUpperBound(constraint, 0, 0.0);
  }
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
  return evaluate(std::span<const double>{parameters}, map, *conditionMap);
}

auto Expression::getPtrToUnknown() -> double* {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v) {
    return &v->value;
  }
  return nullptr;
}

void Expression::markKnown() {
  for (const auto& node : nodes()) {
    if (node->kind() == ExpressionNode::Kind::Variable) {
      auto variable = std::static_pointer_cast<VariableNode>(node);
      variable->known = true;
    }
  }
}

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

auto Kernel::invert(double value) const -> std::optional<double> {
  switch (kind) {
    case Kind::Unknown:
      return value;
    case Kind::Reciprocal:
      // value = 1 / (inner + param)
      if (value == 0) {
        return std::nullopt;
      }
      return inner->invert((1 / value) - param);
    case Kind::Exp:
      // value = exp(param * inner)
      if (value <= 0) {
        return std::nullopt;
      }
      return inner->invert(std::log(value) / param);
  }
  return std::nullopt;
}

namespace {
/// Interns kernels so that structurally equal kernels share a single pointer
class KernelPool {
 public:
  auto unknown(double* value) -> KernelPtr {
    return intern(Kernel::Kind::Unknown, value, nullptr, 0);
  }
  auto reciprocal(const KernelPtr& inner, double shift) -> KernelPtr {
    return intern(Kernel::Kind::Reciprocal, inner->unknown, inner, shift);
  }
  auto exp(const KernelPtr& inner, double scale) -> KernelPtr {
    return intern(Kernel::Kind::Exp, inner->unknown, inner, scale);
  }

 private:
  auto intern(Kernel::Kind kind, double* unknown, const KernelPtr& inner,
              double param) -> KernelPtr {
    auto [it, inserted] =
        kernels.try_emplace(std::tuple{kind, unknown, inner.get(), param});
    if (inserted) {
      it->second = std::make_shared<const Kernel>(Kernel{
          .kind = kind,
          .unknown = unknown,
          .inner = inner,
          .param = param,
      });
    }
    return it->second;
  }

  std::map<std::tuple<Kernel::Kind, double*, const Kernel*, double>, KernelPtr>
      kernels;
};

auto isConstantForm(const LinearForm& form) -> bool {
  return form.coefficients.empty();
}

auto termForm(const KernelPtr& kernel, double coefficient) -> LinearForm {
  return {.coefficients = {{kernel, coefficient}}};
}

auto scaled(LinearForm form, double factor) -> LinearForm {
  if (factor == 0) {
    return {};
  }
  form.constant *= factor;
  for (auto& [kernel, coefficient] : form.coefficients) {
    coefficient *= factor;
  }
  return form;
}

/// @return `lhs + sign * rhs`
auto sum(LinearForm lhs, const LinearForm& rhs, double sign) -> LinearForm {
  lhs.constant += sign * rhs.constant;
  for (const auto& [kernel, coefficient] : rhs.coefficients) {
    auto& total = lhs.coefficients[kernel];
    total += sign * coefficient;
    // Drop cancelled terms so e.g. (x + 1) - x is recognized as constant
    if (total == 0) {
      lhs.coefficients.erase(kernel);
    }
  }
  return lhs;
}

auto product(const LinearForm& lhs, const LinearForm& rhs)
    -> std::optional<LinearForm> {
  if (isConstantForm(lhs)) {
    return scaled(rhs, lhs.constant);
  }
  if (isConstantForm(rhs)) {
    return scaled(lhs, rhs.constant);
  }
  return std::nullopt;
}

/// @return `1 / form`
auto reciprocal(const LinearForm& form, KernelPool& pool)
    -> std::optional<LinearForm> {
  if (isConstantForm(form)) {
    if (form.constant == 0) {
      return std::nullopt;
    }
    return LinearForm{.constant = 1 / form.constant};
  }
  // A denominator of multiple kernels (e.g. 1/(x + y)) is a function of
  // multiple unknowns, so it can't be replaced by a kernel
  if (form.coefficients.size() != 1) {
    return std::nullopt;
  }
  const auto& [kernel, a] = *form.coefficients.begin();
  const double b = form.constant;
  if (b == 0) {
    switch (kernel->kind) {
      case Kernel::Kind::Reciprocal:
        // 1 / (a / (k + s)) = (k + s) / a
        return scaled(
            sum(termForm(kernel->inner, 1), {.constant = kernel->param}, 1),
            1 / a);
      case Kernel::Kind::Exp:
        // 1 / (a * exp(s * k)) = exp(-s * k) / a
        return termForm(pool.exp(kernel->inner, -kernel->param), 1 / a);
      case Kernel::Kind::Unknown:
        break;
    }
  }
  // 1 / (a * k + b) = (1 / a) * 1 / (k + b / a)
  return termForm(pool.reciprocal(kernel, b / a), 1 / a);
}

/// @return `exp(form)`
auto exponential(const LinearForm& form, KernelPool& pool)
    -> std::optional<LinearForm> {
  if (isConstantForm(form)) {
    return LinearForm{.constant = std::exp(form.constant)};
  }
  if (form.coefficients.size() != 1) {
    return std::nullopt;
  }
  const auto& [kernel, a] = *form.coefficients.begin();
  // exp(a * k + b) = exp(b) * exp(a * k)
  return termForm(pool.exp(kernel, a), std::exp(form.constant));
}

/// Computes the LinearForm of `node`. Its children must already be in `forms`
///
/// @return the LinearForm, or std::nullopt if `node` is not an affine function
/// of kernels
auto nodeForm(
    const ExpressionNodePtr& node,
    const std::unordered_map<ExpressionNodePtr, std::optional<LinearForm>>&
        forms,
    const ConditionMap& conditionMap, KernelPool& pool)
    -> std::optional<LinearForm> {
  switch (node->kind()) {
    case ExpressionNode::Kind::BinaryOp: {
      auto binOp = std::static_pointer_cast<BinaryOpNode>(node);
      const auto& lhs = forms.at(binOp->lhs);
      const auto& rhs = forms.at(binOp->rhs);
      if (!lhs || !rhs) {
        return std::nullopt;
      }
      switch (binOp->op) {
        case BinaryOpNode::Op::MUL:
          return product(*lhs, *rhs);
        case BinaryOpNode::Op::DIV: {
          auto inverse = reciprocal(*rhs, pool);
          if (!inverse) {
            return std::nullopt;
          }
          return product(*lhs, *inverse);
        }
        case BinaryOpNode::Op::ADD:
          return sum(*lhs, *rhs, 1);
        case BinaryOpNode::Op::SUB:
          return sum(*lhs, *rhs, -1);
      }
      break;
    }
    case ExpressionNode::Kind::TernaryOp: {
      auto ternOp = std::static_pointer_cast<TernaryOpNode>(node);
      return forms.at(conditionMap.at(ternOp->condition) ? ternOp->valIfTrue
                                                         : ternOp->valIfFalse);
    }
    case ExpressionNode::Kind::UnaryOp: {
      auto unOp = std::static_pointer_cast<UnaryOpNode>(node);
      const auto& operand = forms.at(unOp->operand);
      if (!operand) {
        return std::nullopt;
      }
      switch (unOp->op) {
        case UnaryOpNode::Op::EXP:
          return exponential(*operand, pool);
        case UnaryOpNode::Op::NEG:
          return scaled(*operand, -1);
      }
      break;
    }
    case ExpressionNode::Kind::Variable: {
      auto variable = std::static_pointer_cast<VariableNode>(node);
      if (variable->known) {
        return LinearForm{.constant = variable->value};
      }
      return termForm(pool.unknown(&variable->value), 1);
    }
  }
  return std::nullopt;
}
}  // namespace

auto linearize(const std::vector<Expression>& expressions,
               const ConditionMap& conditionMap)
    -> std::optional<LinearSystem> {
  auto pool = KernelPool{};
  // A node that can't be linearized only matters if it is reachable from a
  // root through the branches selected by `conditionMap`, so failures are
  // recorded rather than returned immediately
  auto forms =
      std::unordered_map<ExpressionNodePtr, std::optional<LinearForm>>{};
  auto system = LinearSystem{};
  system.rows.reserve(expressions.size());
  for (const auto& expression : expressions) {
    for (const auto& node : expression.nodes()) {
      if (!forms.contains(node)) {
        forms[node] = nodeForm(node, forms, conditionMap, pool);
      }
    }
    const auto& form = forms.at(expression.root);
    if (!form) {
      return std::nullopt;
    }
    for (const auto& [kernel, coefficient] : form->coefficients) {
      auto [it, inserted] = system.kernels.try_emplace(kernel->unknown, kernel);
      // Each unknown must be replaced by a single kernel, otherwise e.g.
      // y + 1/y would be treated as two independent unknowns
      if (!inserted && it->second != kernel) {
        return std::nullopt;
      }
    }
    system.rows.push_back(*form);
  }
  return system;
}

auto isLinear(const std::vector<Expression>& expressions,
              const ConditionMap& conditionMap) -> bool {
  return linearize(expressions, conditionMap).has_value();
}
}  // namespace circuitsolver::expression
