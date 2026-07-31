#ifndef EXPRESSION_H
#define EXPRESSION_H

#include <ceres/ceres.h>

#include <iostream>
#include <memory>

#include "circuit_solver/expressionCostFunctor.h"
#include "circuit_solver/expressionNode.h"

class Expression;

namespace std {

/**
 * Exponentiates an expression
 *
 * @return an Expression representing e^this
 */
auto exp(Expression arg) -> Expression;
}  // namespace std

/**
 * Represents an arithmetic expression that can be built with variables of
 * unknown values
 *
 * Currently supported operations:
 * +, -, /, *, exp()
 * TODO: it could potentially improve performance to cleanup unnecessary nodes
 * while building the expression tree. Additionally, this would allow us to use
 * this class more generally for things like symbolic differentiation, etc.
 * TODO: support additional assignment operators
 * TODO: support operators between int/double and Expression
 */
class Expression {
 public:
  /**
   * Creates an expression that consists of a single unknown value
   */
  Expression();
  Expression(const Expression& other);
  auto operator=(const Expression& other) -> Expression&;

  /**
   * Creates an expression with a single known value
   *
   * @param value - the value of the resultant Expression
   */
  Expression(double value);

  // TODO: check if this is needed
  ~Expression();

  /**
   * Adds two expressions
   *
   * @param rhs - the expression to add to this one
   * @return a new Expression that represents this + rhs
   */
  auto operator+(Expression rhs) const -> Expression;

  /**
   * Subtracts two expressions
   *
   * @param rhs - the expression to subtract from this one
   * @return a new Expression that represents this - rhs
   */
  auto operator-(Expression rhs) const -> Expression;

  /**
   * Multiplies two expressions
   *
   * @param rhs - the expression to multiply by this one
   * @return a new Expression that represents this * rhs
   */
  auto operator*(Expression rhs) const -> Expression;

  /**
   * Divides two expressions
   *
   * @param rhs - the expression to divide this one by
   * @return a new Expression that represents this / rhs
   */
  auto operator/(Expression rhs) const -> Expression;

  /**
   * Negates an expression
   * @return a new Expression that represents -this
   */
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

  /**
   * Checks if two Expressions are equal
   *
   * @return true if equal, otherwise false
   */
  auto operator==(const Expression& rhs) const -> bool;
  auto operator==(double rhs) const -> bool;
  auto operator!=(const Expression& rhs) const -> bool;

  /**
   * Checks if this expression is a constant value
   *
   * @return true if this is a constant or false if there are one or more
   * unknowns
   */
  auto isConstant() const -> bool;

  /**
   * Gets the unknowns this Expression depends on
   *
   * @return a vector of double* where each entry points to the value of one of
   * the unknowns of this expression
   */
  auto getUnknowns() const -> const std::vector<double*>&;

  auto getDiscontinuities() -> std::unordered_set<double*>;

  auto getDiscontinuityErrors() -> std::vector<Expression>;

  auto getMutableUnknowns() -> std::vector<double*>;

  auto getNumUnknowns() const -> size_t;

  auto getCostFunction()
      -> ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>*;

  /**
   * Evaluates the Expression, replacing unknowns with 0
   *
   * @return the value of the Expression
   */
  auto evaluate() const -> double;

  auto evaluate(double const* parameters) const -> double;

  auto getPtrToUnknown() -> double*;

  /**
   * If `this` represents a single unknown, changes that unknown to now have the
   * known quantity `value`. Otherwise discards all information represented by
   * `this`, making it represent a single known quantity: `value`.
   *
   * @param value the value to set `this` to
   */
  void setValue(double value);

  void setValues(double const* values);

  void markKnown();

  void addToProblem(ceres::Problem& problem);

 private:
  /**
   * Obtain a mapping of double* to array indices for function arguments.
   * Since the unknowns are stored in a tree ADT we need a way to translate
   * between
   */
  auto getMap() const -> const ExpressionMap&;
  void updateMapAndUnknowns() const;
  Expression(ExpressionNodePtr root);
  ExpressionNodePtr root;
  mutable std::shared_ptr<ExpressionMap> map;
  mutable std::shared_ptr<std::vector<double*>> unknowns;
  friend auto operator<<(std::ostream& out, const Expression& e)
      -> std::ostream&;
  friend auto std::exp(Expression arg) -> Expression;
};

auto getDefaultOptions() -> ceres::Solver::Options;

#endif
