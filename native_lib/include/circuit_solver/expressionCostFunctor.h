#ifndef EXPRESSION_COST_FUNCTOR_H
#define EXPRESSION_COST_FUNCTOR_H

#include <span>
#include <utility>
#include <vector>

#include "circuit_solver/expression.h"
#include "circuit_solver/expressionNode.h"

class ExpressionCostFunctor {
 public:
  ExpressionCostFunctor(circuitsolver::expression::Expression expression,
                        ExpressionMap map, ConditionMap conditionMap)
      : expression(std::move(expression)),
        map(std::move(map)),
        conditionMap(std::move(conditionMap)) {}

  template <typename T>
  auto operator()(T const* const* parameters, T* residuals) -> bool {
    // Each unknown is its own size 1 parameter block. Ceres only stores blocks
    // contiguously when computing jacobians, so they must be read individually
    std::span<T const* const> parameters_by_block_span{parameters, map.size()};
    std::span<T> residuals_span{residuals, 1};

    std::vector<T> parameter_values;
    parameter_values.reserve(map.size());
    for (T const* block : parameters_by_block_span) {
      parameter_values.push_back(*block);
    }
    std::span<const T> parameters_span{parameter_values};
    residuals_span[0] = expression.evaluate(parameters_span, map, conditionMap);
    return true;
  }

 private:
  circuitsolver::expression::Expression expression;
  ExpressionMap map;
  ConditionMap conditionMap;
};

#endif  // !EXPRESSION_COST_FUNCTOR_H
