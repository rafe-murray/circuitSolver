#pragma once

#include <ceres/ceres.h>
#include <ceres/problem.h>
#include <fmt/format.h>

#include <cassert>
#include <cstddef>
#include <iostream>
#include <memory>
#include <span>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

#include "circuit_solver/expressionIterator.h"
#include "circuit_solver/expressionNode.h"

class ExpressionCostFunctor;

namespace circuitsolver::expression {
class Expression;

/// Exponentiates an expression
///
/// @return an Expression representing e^this
auto exp(Expression arg) -> Expression;

/// Represents an arithmetic expression that can be built with variables of
/// unknown values
///
/// Currently supported operations:
/// +, -, /, *, exp()
/// TODO: it could potentially improve performance to cleanup unnecessary nodes
/// while building the expression tree. Additionally, this would allow us to use
/// this class more generally for things like symbolic differentiation, etc.
/// TODO: support additional assignment operators
/// TODO: support operators between int/double and Expression
class Expression {
 public:
  /// Creates an expression that consists of a single unknown value
  Expression();

  /// Creates an expression with a single known value
  ///
  /// @param value the value of the resultant Expression
  Expression(double value);

  /// Adds two expressions
  ///
  /// @param rhs the expression to add to this one
  /// @return a new Expression that represents this + rhs
  auto operator+(Expression rhs) const -> Expression;

  /// Subtracts two expressions
  ///
  /// @param rhs the expression to subtract from this one
  /// @return a new Expression that represents `this - rhs`
  auto operator-(Expression rhs) const -> Expression;

  /// Multiplies two expressions
  ///
  /// @param rhs - the expression to multiply by this one
  /// @return a new Expression that represents this * rhs
  auto operator*(Expression rhs) const -> Expression;

  /// Divides two expressions
  ///
  /// @param rhs - the expression to divide this one by
  /// @return a new Expression that represents this / rhs
  auto operator/(Expression rhs) const -> Expression;

  /// Negates an expression
  /// @return a new Expression that represents -this
  auto operator-() const -> Expression;

  auto operator=(double rhs) -> Expression&;

  auto operator+=(const Expression& rhs) -> Expression&;
  auto operator-=(const Expression& rhs) -> Expression&;

  // TODO: add docs for these methods
  auto operator<(const Expression& rhs) const -> Condition;
  auto operator<=(const Expression& rhs) const -> Condition;
  auto operator>(const Expression& rhs) const -> Condition;
  auto operator>=(const Expression& rhs) const -> Condition;
  // Condition operator!=(Expression rhs) const;
  // Condition equals(Expression rhs) const;
  static auto makeConditional(const Condition& condition, Expression valIfTrue,
                              Expression valIfFalse) -> Expression;

  /// Checks if two Expressions are equal
  ///
  /// @return true if equal, otherwise false
  auto operator==(const Expression& rhs) const -> bool;
  auto operator==(double rhs) const -> bool;
  auto operator!=(const Expression& rhs) const -> bool;

  /// Checks if this expression is a constant value
  ///
  /// @return true if this is a constant or false if there are one or more
  /// unknowns
  auto isConstant() const -> bool;

  auto isLinear() const -> bool;

  /// Gets the unknowns this Expression depends on
  ///
  /// @return a vector of double* where each entry points to the value of one
  /// of the unknowns of this expression
  // auto getUnknowns() const -> const std::vector<double*>&;

  /// Gets the `Conditions` this expression depends on
  ///
  /// @return a set of the `Condition`s used in `this`
  [[nodiscard]] auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>>;

  auto getUnknowns() -> std::vector<double*>;

  auto getNumUnknowns() const -> size_t;

  auto getCostFunction()
      -> ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>*;

  /// Evaluates the Expression, replacing unknowns with 0
  ///
  /// @return the value of the Expression
  auto evaluate() const -> double;

  // auto evaluate(std::span<const double> parameters) const -> double;
  class NodeNotFoundException : public std::runtime_error {};
  class InvalidEnumValue : public std::runtime_error {
   public:
    explicit InvalidEnumValue(const std::string& msg)
        : std::runtime_error(msg) {}
  };

  template <typename T>
  auto evaluate(std::span<const T> parameters, const ExpressionMap& map,
                const ConditionMap& conditionMap) const -> T {
    auto values = std::unordered_map<ExpressionNodePtr, T>{};
    for (const auto& node : nodes()) {
      assert(node);
      switch (node->kind()) {
        case ExpressionNode::Kind::BinaryOp: {
          auto binOp = std::static_pointer_cast<BinaryOpNode>(node);
          switch (binOp->op) {
            case BinaryOpNode::Op::MUL:
              values[binOp] = values[binOp->lhs] * values[binOp->rhs];
              break;
            case BinaryOpNode::Op::DIV:
              values[binOp] = values[binOp->lhs] / values[binOp->rhs];
              break;
            case BinaryOpNode::Op::ADD:
              values[binOp] = values[binOp->lhs] + values[binOp->rhs];
              break;
            case BinaryOpNode::Op::SUB:
              values[binOp] = values[binOp->lhs] - values[binOp->rhs];
              break;
            default:
              throw InvalidEnumValue{fmt::format("Unknown Binary Op: {}",
                                                 fmt::underlying(binOp->op))};
          }
        }
        case ExpressionNode::Kind::TernaryOp: {
          auto ternOp = std::static_pointer_cast<TernaryOpNode>(node);
          if (conditionMap.at(ternOp->condition)) {
            values[ternOp] = values[ternOp->valIfTrue];
          } else {
            values[ternOp] = values[ternOp->valIfFalse];
          }
        }
        case ExpressionNode::Kind::UnaryOp: {
          auto unOp = std::static_pointer_cast<UnaryOpNode>(node);
          switch (unOp->op) {
            case UnaryOpNode::Op::EXP:
              values[unOp] = ceres::exp(values[unOp->operand]);
              break;
            case UnaryOpNode::Op::NEG:
              values[unOp] = -values[unOp->operand];
              break;
            default:
              throw InvalidEnumValue{fmt::format("Unknown Unary Op: {}",
                                                 fmt::underlying(unOp->op))};
          }
        }
        case ExpressionNode::Kind::Variable: {
          auto variable = std::static_pointer_cast<VariableNode>(node);
          if (variable->known) {
            values[variable] = T(variable->value);
          } else {
            values[variable] = parameters[map.at(&variable->value)];
          }
          break;
        }
      }
    }
    return values[root];
  }
  auto getPtrToUnknown() -> double*;

  /// If `this` represents a single unknown, changes that unknown to now have
  /// the known quantity `value`. Otherwise discards all information
  /// represented by `this`, making it represent a single known quantity:
  /// `value`.
  ///
  /// @param value the value to set `this` to
  void setValue(double value);

  void setValues(double const* values);

  void markKnown();

  void addToProblem(ceres::Problem& problem,
                    const ConditionMap& conditionMap) const;
  void addToProblem(ceres::Problem& problem) const;

  /// Restricts `problem` to solutions where `condition` has the value given by
  /// `conditionMap`
  ///
  /// @param problem the problem to add the restriction to
  /// @param condition the condition to enforce
  /// @param conditionMap the assumed value of each condition
  static void addConditionToProblem(
      ceres::Problem& problem,
      const std::shared_ptr<const Condition>& condition,
      const ConditionMap& conditionMap);

  void setConditionMap(const ConditionMap& conditionMap);

 private:
  /// Obtain a mapping of double* to array indices for function arguments.
  /// Since the unknowns are stored in a tree ADT we need a way to translate
  /// between
  auto getMap() const -> const ExpressionMap&;
  void updateInternalState() const;
  auto defaultConditionMap() const -> ConditionMap;

  class NodeTraversal {
   public:
    explicit NodeTraversal(ExpressionNodePtr root) : root(std::move(root)) {}
    auto begin() -> ExpressionIterator { return ExpressionIterator{root}; }
    auto end() -> ExpressionIterator { return ExpressionIterator{}; }

   private:
    ExpressionNodePtr root;
  };

  auto nodes() const -> NodeTraversal { return NodeTraversal{root}; }
  Expression(ExpressionNodePtr root);

  ExpressionNodePtr root;

  // Lazily computed values
  mutable std::shared_ptr<ExpressionMap> map;
  mutable std::shared_ptr<std::vector<double*>> unknowns;
  mutable std::shared_ptr<ConditionMap> conditionMap;

  friend auto operator<<(std::ostream& out, const Expression& e)
      -> std::ostream&;
  friend auto exp(Expression arg) -> Expression;
};

auto getDefaultOptions() -> ceres::Solver::Options;

}  // namespace circuitsolver::expression
