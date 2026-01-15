#ifndef EXPRESSION_H
#define EXPRESSION_H

#include <ceres/ceres.h>

#include <iostream>

#include "expressionCostFunctor.h"
#include "expressionNode.h"

class Expression;

namespace std {

/**
 * Exponentiates an expression
 *
 * @return an Expression representing e^this
 */
Expression exp(Expression arg);
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
  /*
   * Creates an expression that consists of a single unknown value
   */
  Expression();

  /*
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
  Expression operator+(Expression rhs) const;

  /**
   * Subtracts two expressions
   *
   * @param rhs - the expression to subtract from this one
   * @return a new Expression that represents this - rhs
   */
  Expression operator-(Expression rhs) const;

  /**
   * Multiplies two expressions
   *
   * @param rhs - the expression to multiply by this one
   * @return a new Expression that represents this * rhs
   */
  Expression operator*(Expression rhs) const;

  /**
   * Divides two expressions
   *
   * @param rhs - the expression to divide this one by
   * @return a new Expression that represents this / rhs
   */
  Expression operator/(Expression rhs) const;

  /**
   * Negates an expression
   * @return a new Expression that represents -this
   */
  Expression operator-() const;

  Expression& operator=(double rhs);

  Expression& operator+=(const Expression& rhs);
  Expression& operator-=(const Expression& rhs);

  // TODO: add docs for these methods
  Condition operator<(Expression rhs) const;
  Condition operator<=(Expression rhs) const;
  Condition operator>(Expression rhs) const;
  Condition operator>=(Expression rhs) const;
  // Condition operator!=(Expression rhs) const;
  // Condition equals(Expression rhs) const;
  static Expression makeConditional(Condition condition, Expression valIfTrue,
                                    Expression valIfFalse);

  /**
   * Checks if two Expressions are equal
   *
   * @return true if equal, otherwise false
   */
  bool operator==(const Expression& rhs) const;
  bool operator==(double rhs) const;
  bool operator!=(const Expression& rhs) const;

  /**
   * Checks if this expression is a constant value
   *
   * @return true if this is a constant or false if there are one or more
   * unknowns
   */
  bool isConstant() const;

  /**
   * Gets the unknowns this Expression depends on
   *
   * @return a vector of double* where each entry points to the value of one of
   * the unknowns of this expression
   */
  std::unordered_set<const double*> getUnknowns() const;

  std::unordered_set<double*> getDiscontinuities();

  std::vector<Expression> getDiscontinuityErrors();

  std::vector<double*> getMutableUnknowns();

  size_t getNumUnknowns() const;

  ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>* getCostFunction();

  /**
   * Evaluates the Expression, replacing unknowns with 0
   *
   * @return the value of the Expression
   */
  double evaluate() const;

  double evaluate(double const* parameters) const;

  double* getPtrToUnknown();

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
  ExpressionMap getMap() const;
  Expression(ExpressionNodePtr root);
  ExpressionNodePtr root;
  friend std::ostream& operator<<(std::ostream& out, const Expression& e);
  friend Expression std::exp(Expression arg);
};

ceres::Solver::Options getDefaultOptions();

#endif
