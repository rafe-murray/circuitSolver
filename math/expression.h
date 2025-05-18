#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "expressionNode.h"
#include <iostream>
#include <nlopt.hpp>

struct FunctionData {
  shared_ptr<ExpressionNode> expression;
  const expressionMap map;
  FunctionData(shared_ptr<ExpressionNode> expression, const expressionMap &map)
      : expression(expression), map(map) {}
};

class Expression {
public:
  Expression();
  Expression(double value);
  ~Expression();
  Expression operator+(const Expression &rhs) const;
  Expression operator-(const Expression &rhs) const;
  Expression operator*(const Expression &rhs) const;
  Expression operator/(const Expression &rhs) const;
  Expression operator-() const;
  bool operator==(const Expression &rhs) const;
  Expression exp() const;

  nlopt::vfunc toFunction();
  void *getFunctionData();
  set<const Variable *> getUnknowns();
  expressionMap getMap();

  // FIXME: remove when done debugging!
  double getValue();
  void print(std::ostream &out = std::cout) const;

  // FIXME: Make this private
  shared_ptr<ExpressionNode> root;

private:
  Expression(shared_ptr<ExpressionNode> root);
  friend std::hash<Expression>;
};

namespace std {
template <> struct hash<Expression> {
  size_t operator()(const Expression &v) const {
    hash<shared_ptr<const ExpressionNode>> pointerHash;
    return pointerHash(v.root);
  }
};
}; // namespace std
#endif
