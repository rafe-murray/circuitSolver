#ifndef EXPRESSION_COST_FUNCTOR_H
#define EXPRESSION_COST_FUNCTOR_H

#include "expressionNode.h"

class ExpressionCostFunctor {
 public:
  ~ExpressionCostFunctor() {}
  ExpressionCostFunctor(ExpressionNodePtr expressionNode,
                        const ExpressionMap& map)
      : expressionNode(expressionNode), map(map) {}
  template <typename T>
  bool operator()(T const* const* parameters, T* residuals) {
    residuals[0] = expressionNode::evaluate(expressionNode, parameters[0], map);
    return true;
  }

 private:
  ExpressionNodePtr expressionNode;
  ExpressionMap map;
};

#endif  // !EXPRESSION_COST_FUNCTOR_H
