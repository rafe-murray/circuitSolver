#pragma once

#include <ceres/ceres.h>
#include <ceres/problem.h>

#include <cassert>
#include <cstddef>
#include <cstdint>
#include <iostream>
#include <memory>
#include <optional>
#include <span>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

#include "circuit_solver/expressionIterator.h"
#include "circuit_solver/expressionNode.h"

class ExpressionCostFunctor;

namespace circuitsolver::expression {
class Expression;

/// A function of a single unknown that a linear solver can treat as an unknown
/// in its own right. Every kernel is injective, so the value of the unknown can
/// be recovered from the value of the kernel with `invert`.
///
/// Kernels are canonicalized so that two kernels that are affine functions of
/// one another are represented by the same kernel (e.g. 2/y and 1/y are both
/// expressed in terms of the kernel 1/y).
struct Kernel {
  enum class Kind : uint8_t {
    /// The unknown itself
    Unknown,
    /// `1 / (inner + param)`
    Reciprocal,
    /// `exp(param * inner)`
    Exp,
  };

  Kind kind;

  /// The single unknown this kernel depends on
  double* unknown;

  /// The kernel this one is applied to. `nullptr` iff `kind == Kind::Unknown`
  std::shared_ptr<const Kernel> inner;

  /// The shift (`Reciprocal`) or scale (`Exp`) applied to `inner`
  double param = 0;

  /// Computes the value of `unknown` that results in this kernel having the
  /// value `value`
  ///
  /// @param value the value of this kernel
  /// @return the value of `unknown`, or std::nullopt if `value` is outside of
  /// the range of this kernel
  [[nodiscard]] auto invert(double value) const -> std::optional<double>;
};
using KernelPtr = std::shared_ptr<const Kernel>;

/// An affine function of kernels: `constant + sum(coefficient * kernel)`
struct LinearForm {
  double constant = 0;
  std::unordered_map<KernelPtr, double> coefficients;
};

/// A system of expressions rewritten as a linear system over kernels
struct LinearSystem {
  /// `rows[i]` is equivalent to the i-th linearized expression. Each row is to
  /// be solved for `rows[i] == 0`
  std::vector<LinearForm> rows;

  /// The kernel that replaces each unknown. Every kernel used in `rows` appears
  /// here exactly once, so the map from unknowns to kernels is a bijection
  std::unordered_map<double*, KernelPtr> kernels;
};

/// Rewrites `expressions` as a linear system by replacing nonlinear
/// subexpressions of a single unknown with kernels (e.g. `x + 1/(1 + 1/y)`
/// becomes `x + z` with `z = 1/(1 + 1/y)`)
///
/// @param expressions the expressions to linearize
/// @param conditionMap the value of every condition the expressions depend on
/// @return the linear system, or std::nullopt if no bijection between the
/// unknowns and a set of kernels makes every expression linear
auto linearize(const std::vector<Expression>& expressions,
               const ConditionMap& conditionMap) -> std::optional<LinearSystem>;

/// Checks if `expressions` can be solved by a linear solver
///
/// @return true iff `linearize(expressions, conditionMap)` succeeds
auto isLinear(const std::vector<Expression>& expressions,
              const ConditionMap& conditionMap) -> bool;

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

  /// Checks if this expression can be solved by a linear solver
  ///
  /// @param conditionMap the value of every condition this expression depends
  /// on
  /// @return true iff `linearize({*this}, conditionMap)` succeeds
  auto isLinear(const ConditionMap& conditionMap) const -> bool;

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
          }
          break;
        }
        case ExpressionNode::Kind::TernaryOp: {
          auto ternOp = std::static_pointer_cast<TernaryOpNode>(node);
          if (conditionMap.at(ternOp->condition)) {
            values[ternOp] = values[ternOp->valIfTrue];
          } else {
            values[ternOp] = values[ternOp->valIfFalse];
          }
          break;
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
          }
          break;
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
    static auto end() -> ExpressionIterator { return ExpressionIterator{}; }

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
  friend auto linearize(const std::vector<Expression>& expressions,
                        const ConditionMap& conditionMap)
      -> std::optional<LinearSystem>;
};

auto getDefaultOptions() -> ceres::Solver::Options;
}  // namespace circuitsolver::expression
