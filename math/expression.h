#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "expressionNode.h"
/*#include <nlopt.hpp>*/

struct FunctionData {
  ExpressionNode *expression;
  const expressionMap map;
  FunctionData(ExpressionNode *expression, const expressionMap map)
      : expression(expression), map(map) {}
};

class Expression {
public:
  Expression();
  Expression operator+(const Expression &rhs) const;
  Expression operator-(const Expression &rhs) const;
  Expression operator*(const Expression &rhs) const;
  Expression operator/(const Expression &rhs) const;
  Expression operator-() const;
  Expression exp() const;

  /*nlopt::vfunc toFunction();*/
  void *getFunctionData();
  set<const Variable *> getUnknowns();
  expressionMap getMap();

private:
  Expression(ExpressionNode *root);
  ExpressionNode *root;
  friend class Variable;
};

#endif
