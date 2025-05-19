#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "expressionCostFunction.h"
#include "expressionNode.h"
#include <ceres/ceres.h>
#include <iostream>
#include <memory>
#include <nlopt.hpp>

struct FunctionData {
  shared_ptr<ExpressionNode> expression;
  const expressionMap map;
  FunctionData(shared_ptr<ExpressionNode> expression, const expressionMap& map)
      : expression(expression), map(map) {}
};

class Expression {
public:
  Expression();
  Expression(double value);
  ~Expression();
  Expression operator+(const Expression& rhs) const;
  Expression operator-(const Expression& rhs) const;
  Expression operator*(const Expression& rhs) const;
  Expression operator/(const Expression& rhs) const;
  Expression operator-() const;
  bool operator==(const Expression& rhs) const;
  Expression exp() const;

  nlopt::vfunc toFunction();
  ExpressionCostFunction* getCostFunction(int n);
  /*void* getFunctionData();*/
  set<Variable*> getUnknowns();
  vector<double*> getUnknownVals();
  expressionMap* getMap();

  // FIXME: remove when done debugging!
  double getValue();
  void print(std::ostream& out = std::cout) const;

  // FIXME: Make this private
  shared_ptr<ExpressionNode> root;

private:
  Expression(shared_ptr<ExpressionNode> root);
  friend std::hash<Expression>;
};

namespace std {
template <> struct hash<Expression> {
  size_t operator()(const Expression& v) const {
    hash<shared_ptr<const ExpressionNode>> pointerHash;
    return pointerHash(v.root);
  }
};
}; // namespace std
#endif
