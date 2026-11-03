#include "circuit_solver/solver.h"

#include <gtest/gtest.h>

#include <cstddef>
#include <expected>
#include <memory>
#include <optional>
#include <unordered_map>
#include <utility>
#include <vector>

#include "circuit_solver/config.h"
#include "circuit_solver/errors.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/expressionNode.h"

using circuitsolver::CircuitSolverError;
using circuitsolver::ErrorType;
using circuitsolver::constants::solutionCostThreshold;
using circuitsolver::solver::PartitionSolver;
using circuitsolver::solver::Solution;
using circuitsolver::solver::Solver;

namespace {
/// Returns a solution with the next cost for each partition, or fails the
/// partition if that cost is `std::nullopt`
class FakePartitionSolver : public PartitionSolver {
 public:
  explicit FakePartitionSolver(std::vector<std::optional<double>> costs)
      : costs(std::move(costs)) {}

  auto Solve(
      const std::vector<Expression>& expressions,
      std::unordered_map<std::shared_ptr<const Condition>, bool> conditionMap)
      -> std::expected<Solution, CircuitSolverError> override {
    auto cost = costs.at(nextPartition++);
    if (!cost.has_value()) {
      return std::unexpected{
          CircuitSolverError{ErrorType::NoSolution, "Partition failed"},
      };
    }
    return Solution{expressions, std::move(conditionMap), *cost};
  }

 private:
  std::vector<std::optional<double>> costs;
  size_t nextPartition = 0;
};

/// Solves an expression with two conditions, which has four partitions
auto solveWithCosts(std::vector<std::optional<double>> costs)
    -> std::expected<Solution, CircuitSolverError> {
  auto x = Expression{};
  auto y = Expression{};
  auto expression = Expression::makeConditional(x > Expression(0.0), x, y) +
                    Expression::makeConditional(y > Expression(0.0), y, x);
  auto solver =
      Solver{std::make_unique<FakePartitionSolver>(std::move(costs))};
  return solver.Solve({expression});
}
}  // namespace

TEST(SolverTest, ChoosesLowestCostSolution) {
  auto result = solveWithCosts({1e-10, 1e-12, 1e-11, 1.0});
  ASSERT_TRUE(result) << result.error().message();
  EXPECT_EQ(result->getCost(), 1e-12);
}

TEST(SolverTest, SkipsFailedPartitions) {
  auto result = solveWithCosts({std::nullopt, std::nullopt, 1e-12, 1e-10});
  ASSERT_TRUE(result) << result.error().message();
  EXPECT_EQ(result->getCost(), 1e-12);
}

TEST(SolverTest, NoSolutionWhenAllPartitionsFail) {
  auto result = solveWithCosts(
      {std::nullopt, std::nullopt, std::nullopt, std::nullopt});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::NoSolution);
}

TEST(SolverTest, NoSolutionWhenBestCostExceedsThreshold) {
  auto cost = solutionCostThreshold * 2;
  auto result = solveWithCosts({cost, cost * 2, std::nullopt, cost * 3});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::NoSolution);
}
