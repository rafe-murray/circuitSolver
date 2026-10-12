#include "circuit_solver/solver.h"

#include <ceres/problem.h>
#include <ceres/solver.h>
#include <fmt/format.h>
#include <spdlog/spdlog.h>

#include <algorithm>
#include <bitset>
#include <cstdint>
#include <expected>
#include <memory>
#include <random>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

#include "circuit_solver/config.h"
#include "circuit_solver/errors.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/expressionNode.h"

namespace circuitsolver::solver {
using constants::unknownSeedStdDeviation;

Solution::Solution(const std::vector<Expression>& solvedExpressions,
                   ConditionMap conditionMap, double cost)
    : cost(cost), conditionMap(std::move(conditionMap)) {
  for (auto expression : solvedExpressions) {
    for (auto* unknown : expression.getUnknowns()) {
      unknownToValue[unknown] = *unknown;
    }
  }
}

void Solution::apply() const {
  for (auto pair : unknownToValue) {
    *pair.first = pair.second;
  }
}

auto Solution::getCost() const -> double { return cost; }
auto Solution::getConditionMap() const -> ConditionMap { return conditionMap; }

NonLinearPartitionSolver::NonLinearPartitionSolver()
    : ceresSolver(std::make_unique<ceres::Solver>()) {}
NonLinearPartitionSolver::NonLinearPartitionSolver(
    std::unique_ptr<ceres::Solver> ceresSolver)
    : ceresSolver(std::move(ceresSolver)) {}

auto NonLinearPartitionSolver::Solve(
    const std::vector<Expression>& expressions,
    std::unordered_map<std::shared_ptr<const Condition>, bool> conditionMap)
    -> std::expected<Solution, CircuitSolverError> {
  auto problem = ceres::Problem{};
  for (const auto& expression : expressions) {
    expression.addToProblem(problem, conditionMap);
  }
  ceres::Solver::Summary summary;
  // TODO: move default options to inline here
  ceresSolver->Solve(getDefaultOptions(), &problem, &summary);
  if (!summary.IsSolutionUsable()) {
    return std::unexpected{
        CircuitSolverError{
            ErrorType::NoSolution,
            "No solution was found for the given inputs",
        },
    };
  }
  // Solving happens in place
  return Solution{expressions, conditionMap, summary.final_cost};
}

void Solver::resetUnknowns(const std::vector<Expression>& expressions) {
  auto rd = std::random_device{};
  auto rng = std::mt19937{rd()};
  auto dist = std::normal_distribution<>{0.0, unknownSeedStdDeviation};
  for (auto expression : expressions) {
    for (auto* unknown : expression.getUnknowns()) {
      *unknown = dist(rng);
    }
  }
}

Solver::Solver()
    : partitionSolver(std::make_unique<NonLinearPartitionSolver>()) {}
Solver::Solver(std::unique_ptr<PartitionSolver> partitionSolver)
    : partitionSolver(std::move(partitionSolver)) {}
auto Solver::Solve(const std::vector<Expression>& expressions)
    -> std::expected<Solution, CircuitSolverError> {
  constexpr int maxNumConditions = 32;
  auto conditions = std::unordered_set<std::shared_ptr<const Condition>>{};
  for (const auto& expression : expressions) {
    conditions.merge(expression.getConditions());
  }
  int numConditions = static_cast<int>(conditions.size());
  if (numConditions >= maxNumConditions) {
    return std::unexpected{
        CircuitSolverError{
            ErrorType::TooManyDiscontinuities,
            fmt::format(
                "Cannot solve circuit since it has too many elements with "
                "discontinuous behaviour. The max is {}; you had {}",
                maxNumConditions, numConditions),
        },
    };
  }
  uint32_t numPartitions = 0;
  if (numConditions > 0) {
    // 2^n partitions: combinations for each discontinuity's high and low case
    numPartitions = uint32_t{1} << numConditions;
  } else {
    numPartitions = 1;
  }
  SPDLOG_DEBUG("numPartitions: {}, numConditions: {}", numPartitions,
               numConditions);
  auto solutions = std::vector<Solution>{};
  solutions.reserve(numPartitions);
  auto conditionMaps = std::vector<ConditionMap>{};
  auto orderedConditions = std::vector<std::shared_ptr<const Condition>>{
      conditions.begin(), conditions.end()};
  for (uint32_t i = 0; i < numPartitions; i++) {
    conditionMaps.emplace_back();
    for (int j = 0; j < numConditions; j++) {
      auto bits = std::bitset<maxNumConditions>(i);
      conditionMaps.at(i)[orderedConditions.at(j)] = bits.test(j);
    }
    auto solution = partitionSolver->Solve(expressions, conditionMaps.at(i));
    if (solution.has_value()) {
      solutions.insert(solutions.begin() + i, solution.value());
      resetUnknowns(expressions);
    }
  }
  return *std::ranges::min_element(solutions, {}, &Solution::getCost);
}
}  // namespace circuitsolver::solver
