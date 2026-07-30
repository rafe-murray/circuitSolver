#ifndef EXPRESSION_COST_FUNCTOR_H
#define EXPRESSION_COST_FUNCTOR_H

#include <utility>

#include "circuit_solver/expressionNode.h"

class ExpressionCostFunctor {
 public:
  ~ExpressionCostFunctor() = default;
  ExpressionCostFunctor(ExpressionNodePtr expressionNode, ExpressionMap map)
      : expressionNode(std::move(std::move(expressionNode))),
        map(std::move(map)) {}
  template <typename T>
  auto operator()(T const* const* parameters, T* residuals) -> bool {
    residuals[0] = expressionNode::evaluate(expressionNode, parameters[0], map);
    return true;
  }

 private:
  ExpressionNodePtr expressionNode;
  ExpressionMap map;
};

#endif  // !EXPRESSION_COST_FUNCTOR_H
