#ifndef EXPRESSION_COST_FUNCTOR_H
#define EXPRESSION_COST_FUNCTOR_H

#include <span>
#include <utility>

#include "circuit_solver/expressionNode.h"

class ExpressionCostFunctor {
 public:
  ExpressionCostFunctor(ExpressionNodePtr expressionNode, ExpressionMap map)
      : expressionNode(std::move(std::move(expressionNode))),
        map(std::move(map)) {}
  template <typename T>
  auto operator()(T const* const* parameters, T* residuals) -> bool {
    // We have only one residual and parameters block
    std::span<T const* const> parameters_by_residual_span{parameters, 1};
    std::span<T> residuals_span{residuals, 1};

    std::span<const T> parameters_span{parameters_by_residual_span[0],
                                       map.size()};
    residuals_span[0] =
        expressionNode::evaluate(expressionNode, parameters_span, map);
    return true;
  }

 private:
  ExpressionNodePtr expressionNode;
  ExpressionMap map;
};

#endif  // !EXPRESSION_COST_FUNCTOR_H
