#ifndef EXPRESSION_COST_FUNCTOR_H
#define EXPRESSION_COST_FUNCTOR_H

#include "circuitsolver/expressionNode.h"
class ExpressionCostFunctor {
public:
  ExpressionCostFunctor(ExpressionNodePtr expressionNode,
                        const ExpressionMap& map)
      : expressionNode(expressionNode), map(map) {}
  template <typename T>
  bool operator()(T const* const* parameters, T* residuals) {
    residuals[0] = expressionNode->evaluate(parameters[0], map);
  }

private:
  ExpressionNodePtr expressionNode;
  ExpressionMap map;
};

#endif // !EXPRESSION_COST_FUNCTOR_H
