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

using circuitsolver::constants::solutionCostThreshold;
using circuitsolver::errors::Error;
using circuitsolver::errors::ErrorType;
using circuitsolver::expression::Expression;
using circuitsolver::solver::LinearPartitionSolver;
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
      -> std::expected<Solution, Error> override {
    auto cost = costs.at(nextPartition++);
    if (!cost.has_value()) {
      return std::unexpected{
          Error{ErrorType::NoSolution, "Partition failed"},
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
    -> std::expected<Solution, Error> {
  auto x = Expression{};
  auto y = Expression{};
  auto expression = Expression::makeConditional(x > Expression(0.0), x, y) +
                    Expression::makeConditional(y > Expression(0.0), y, x);
  auto solver = Solver{std::make_unique<FakePartitionSolver>(std::move(costs))};
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
  auto result =
      solveWithCosts({std::nullopt, std::nullopt, std::nullopt, std::nullopt});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::NoSolution);
}

TEST(SolverTest, NoSolutionWhenBestCostExceedsThreshold) {
  auto cost = solutionCostThreshold * 2;
  auto result = solveWithCosts({cost, cost * 2, std::nullopt, cost * 3});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::NoSolution);
}

TEST(LinearPartitionSolverTest, SolvesLinearSystem) {
  auto x = Expression{};
  auto y = Expression{};
  auto result = LinearPartitionSolver{}.Solve({x + y - 3, x - y - 1}, {});
  ASSERT_TRUE(result) << result.error().message();
  EXPECT_LT(result->getCost(), solutionCostThreshold);
  EXPECT_DOUBLE_EQ(*x.getPtrToUnknown(), 2);
  EXPECT_DOUBLE_EQ(*y.getPtrToUnknown(), 1);
}

TEST(LinearPartitionSolverTest, SolvesSubstitutedSubexpressions) {
  auto x = Expression{};
  auto y = Expression{};
  auto z = Expression{};
  auto one = Expression{1.0};
  // 1/(1 + 1/y) and exp(z) are each replaced with a single unknown
  auto result = LinearPartitionSolver{}.Solve(
      {x + one / (one + one / y) - 3, x - Expression(2.5),
       circuitsolver::expression::exp(z) * 2 + x - 4.5},
      {});
  ASSERT_TRUE(result) << result.error().message();
  EXPECT_LT(result->getCost(), solutionCostThreshold);
  EXPECT_DOUBLE_EQ(*x.getPtrToUnknown(), 2.5);
  // 1/(1 + 1/y) = 0.5
  EXPECT_NEAR(*y.getPtrToUnknown(), 1, 1e-12);
  // exp(z) = 1
  EXPECT_NEAR(*z.getPtrToUnknown(), 0, 1e-12);
}

TEST(LinearPartitionSolverTest, RejectsNonLinearSystem) {
  auto x = Expression{};
  auto y = Expression{};
  auto result = LinearPartitionSolver{}.Solve({x * y - 1, x - 1}, {});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::InvalidInput);
}

TEST(LinearPartitionSolverTest, RejectsUnderdeterminedSystem) {
  auto x = Expression{};
  auto y = Expression{};
  auto result = LinearPartitionSolver{}.Solve({x + y - 1}, {});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::NoSolution);
}

TEST(LinearPartitionSolverTest, RejectsKernelValueOutsideRange) {
  auto x = Expression{};
  // exp(x) = -1 has no solution
  auto result = LinearPartitionSolver{}.Solve(
      {circuitsolver::expression::exp(x) + 1}, {});
  ASSERT_FALSE(result);
  EXPECT_EQ(result.error().type(), ErrorType::NoSolution);
}

TEST(LinearPartitionSolverTest, SolverChoosesConsistentPartition) {
  auto x = Expression{};
  // x > 0 gives x = 2. x <= 0 gives x = 3, which contradicts its partition
  auto expression =
      Expression::makeConditional(x > Expression(0.0), x - 2, x - 3);
  auto solver = Solver{std::make_unique<LinearPartitionSolver>()};
  auto result = solver.Solve({expression});
  ASSERT_TRUE(result) << result.error().message();
  result->apply();
  EXPECT_DOUBLE_EQ(*x.getPtrToUnknown(), 2);
}
