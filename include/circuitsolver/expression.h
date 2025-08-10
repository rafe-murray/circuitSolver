#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "expressionCostFunctor.h"
#include "expressionNode.h"
#include <ceres/ceres.h>
#include <iostream>

class ExpressionCostFunction;

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
  Expression operator+(const Expression& rhs) const;

  /**
   * Subtracts two expressions
   *
   * @param rhs - the expression to subtract from this one
   * @return a new Expression that represents this - rhs
   */
  Expression operator-(const Expression& rhs) const;

  /**
   * Multiplies two expressions
   *
   * @param rhs - the expression to multiply by this one
   * @return a new Expression that represents this * rhs
   */
  Expression operator*(const Expression& rhs) const;

  /**
   * Divides two expressions
   *
   * @param rhs - the expression to divide this one by
   * @return a new Expression that represents this / rhs
   */
  Expression operator/(const Expression& rhs) const;

  /**
   * Negates an expression
   * @return a new Expression that represents -this
   */
  Expression operator-() const;

  Expression& operator=(double rhs);

  // TODO: add docs for these methods
  Condition operator<(const Expression& rhs) const;
  Condition operator<=(const Expression& rhs) const;
  Condition operator>(const Expression& rhs) const;
  Condition operator>=(const Expression& rhs) const;
  Condition operator!=(const Expression& rhs) const;
  Condition equals(const Expression& rhs) const;
  static Expression makeConditional(Condition condition,
                                    const Expression& valIfTrue,
                                    const Expression& valIfFalse);

  /**
   * Checks if two Expressions are equal
   *
   * @return true if equal, otherwise false
   */
  bool operator==(const Expression& rhs) const;

  /**
   * Checks if this expression is a constant value
   *
   * @return true if this is a constant or false if there are one or more
   * unknowns
   */
  bool isConstant() const;

  /**
   * Exponentiates an expression
   *
   * @return an Expression representing e^this
   */
  static Expression exp(const Expression& arg);

  /**
   * Gets the unknowns this Expression depends on
   *
   * @return a vector of double* where each entry points to the value of one of
   * the unknowns of this expression
   */
  std::unordered_set<const double*> getUnknowns() const;

  int getNumUnknowns() const;

  ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor> getCostFunction();

  /**
   * Evaluates the Expression, replacing unknowns with 0
   *
   * @return the value of the Expression
   */
  double evaluate() const;

  double evaluate(double const* parameters, const ExpressionMap& map) const;

  double* getPtrToUnknown();

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
};
#endif
