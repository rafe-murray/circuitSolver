#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "condition.h"
#include "expressionNode.h"
#include <ceres/ceres.h>
#include <iostream>
#include <memory>

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
   * @return true if this is a constant or true if there are one or more
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
   * Gets a cost function for this Expression
   */
  ExpressionCostFunction* getCostFunction();

  /**
   * Gets the unknowns this Expression depends on
   *
   * @return a vector of double* where each entry points to the value of one of
   * the unknowns of this expression
   */
  vector<double*> getUnknownVals();

  /**
   * Gets the value of this expression given the current values set for the
   * unknowns (i.e., by modifying the values returned from `getUnknownVals`)
   *
   * @return the value of the Expression
   */
  double getValue();

  // TODO: turn this into an operator<< overload and use an inorder traversal to
  // print vals maybe with unknown@0x12345678 for the unknowns
  void print(std::ostream& out = std::cout) const;

  // FIXME: Make this private
  shared_ptr<ExpressionNode> root;

private:
  /**
   * Obtain a mapping of Variable* to array indices for function arguments.
   * Since the unknowns are stored in a tree ADT we need a way to translate
   * between
   * TODO: change expressionMap from using Variable* pointers to using double*
   * pointers then remove the unnecessary getUnknowns, rename getUnknownVals
   */
  expressionMap* getMap();
  set<VariableNode*> getUnknowns();
  Expression(shared_ptr<ExpressionNode> root);
  friend std::hash<Expression>;
  friend ostream& operator<<(ostream& out, const Expression& e);
};

// Define a std::hash object so that Expressions can be used as keys in
// std::unordered_map or std::unordered_set containers
namespace std {
template <> struct hash<Expression> {
  size_t operator()(const Expression& v) const {
    hash<shared_ptr<const ExpressionNode>> pointerHash;
    return pointerHash(v.root);
  }
};
}; // namespace std
#endif
