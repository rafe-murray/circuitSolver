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
using constants::solutionCostThreshold;
using constants::unknownSeedStdDeviation;
using errors::ErrorType;

Solution::Solution(
    const std::vector<circuitsolver::expression::Expression>& solvedExpressions,
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
    -> std::expected<Solution, Error> {
  auto problem = ceres::Problem{};
  for (const auto& expression : expressions) {
    expression.addToProblem(problem, conditionMap);
  }
  for (const auto& conditionPair : conditionMap) {
    Expression::addConditionToProblem(problem, conditionPair.first,
                                      conditionMap);
  }
  ceres::Solver::Summary summary;
  // TODO: move default options to inline here
  ceresSolver->Solve(expression::getDefaultOptions(), &problem, &summary);
  if (!summary.IsSolutionUsable()) {
    return std::unexpected{
        Error{
            ErrorType::NoSolution,
            "No solution was found for the given inputs",
        },
    };
  }
  // Solving happens in place
  return Solution{expressions, conditionMap, summary.final_cost};
}

auto LinearPartitionSolver::Solve(
    const std::vector<Expression>& expressions,
    std::unordered_map<std::shared_ptr<const Condition>, bool> conditionMap)
    -> std::expected<Solution, Error> {
  // We have a set of expressions that we know are equal to 0.
  // We want to determine if they can all be represented as linear combinations
  // of the unknowns If yes, then we also need to determine the coefficients of
  // this matrix
  // We have already applied arithmetic identities to simplify the expressions
  // (we do this in the factory constructors for `Expression`) Some rules:
  // - If there is an exp node then there is no linear system
  // - If any Variable multiplies or divides another variable at any level,
  // there is no linear system
  // - If any Variable is a divisor, a linear system can only be constructed if
  // it is not used anywhere else, except also as a divisor (simpler to say it
  // is never a linear system)
  //
  // We have a tree to walk
  //
  // Some examples:
  // x + y + z: linear
  //
  //     +
  //    / \
  //   +   z
  //  / \
  // x   y
  //
  // x * y + 1: non-linear
  //
  //     +
  //    / \
  //   *   1
  //  / \
  // x   y
  //
  // (x + y) / 3: linear
  //
  // Let f(x) denote a set of nodes dependent on variable x that is connected by
  // * and / nodes. Then f(x) +- y is only linear if y is either:
  // - not dependent on x
  // - A constant multiple of f(x)
  // ---------------------------------------------------------------------------
  // After we've determined that the system is linear:
  //
  // - Need the coefficients of each Variable (or reciprocal, see above)
  // - We also need to ensure that we properly manage cases where there are
  // multiple terms with the same variable but different coefficients. E.g., x +
  // 1 + 2x
}

void Solver::resetUnknowns(const std::vector<Expression>& expressions) {
  auto rd = std::random_device{};
  auto rng = std::mt19937{rd()};
  auto dist = std::normal_distribution{0.0, unknownSeedStdDeviation};
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
    -> std::expected<Solution, errors::Error> {
  constexpr int maxNumConditions = 32;
  auto conditions = std::unordered_set<std::shared_ptr<const Condition>>{};
  for (const auto& expression : expressions) {
    conditions.merge(expression.getConditions());
  }
  int numConditions = static_cast<int>(conditions.size());
  if (numConditions >= maxNumConditions) {
    return std::unexpected{
        Error{
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
      solutions.push_back(std::move(solution.value()));
    }
    resetUnknowns(expressions);
  }
  if (solutions.empty()) {
    return std::unexpected{
        Error{
            ErrorType::NoSolution,
            "No solution was found for the given inputs",
        },
    };
  }
  const auto& bestSolution =
      *std::ranges::min_element(solutions, {}, &Solution::getCost);
  if (bestSolution.getCost() > solutionCostThreshold) {
    return std::unexpected{
        Error{
            ErrorType::NoSolution,
            fmt::format("No solution was within cost threshold {}. The best "
                        "cost was {}",
                        solutionCostThreshold, bestSolution.getCost()),
        },
    };
  }
  return bestSolution;
}
auto isExpressionLinear(const Expression& expression) -> bool { return {}; }

auto isPartitionLinear(const std::vector<Expression>& expressions,
                       ConditionMap conditionMap) -> bool {
  return {};
}
}  // namespace circuitsolver::solver
