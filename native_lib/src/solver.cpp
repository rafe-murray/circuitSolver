#include "circuit_solver/solver.h"

#include <ceres/problem.h>
#include <ceres/solver.h>
#include <fmt/format.h>
#include <spdlog/spdlog.h>

#include <Eigen/Dense>
#include <algorithm>
#include <bitset>
#include <cstdint>
#include <expected>
#include <memory>
#include <optional>
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
  auto system = expression::linearize(expressions, conditionMap);
  if (!system) {
    return std::unexpected{
        Error{
            ErrorType::InvalidInput,
            "The expressions are not linear in this partition",
        },
    };
  }

  // Each kernel is the unknown of one column
  auto columns = std::vector<expression::KernelPtr>{};
  columns.reserve(system->kernels.size());
  auto columnIndices =
      std::unordered_map<expression::KernelPtr, Eigen::Index>{};
  for (const auto& [unknown, kernel] : system->kernels) {
    columnIndices[kernel] = static_cast<Eigen::Index>(columns.size());
    columns.push_back(kernel);
  }
  const auto numRows = static_cast<Eigen::Index>(system->rows.size());
  const auto numColumns = static_cast<Eigen::Index>(columns.size());

  // Each row is `constant + sum(coefficient * kernel) == 0`
  Eigen::MatrixXd a = Eigen::MatrixXd::Zero(numRows, numColumns);
  Eigen::VectorXd b(numRows);
  for (Eigen::Index i = 0; i < numRows; i++) {
    const auto& row = system->rows[i];
    b(i) = -row.constant;
    for (const auto& [kernel, coefficient] : row.coefficients) {
      a(i, columnIndices.at(kernel)) = coefficient;
    }
  }

  if (numColumns > 0) {
    auto qr = a.colPivHouseholderQr();
    Eigen::VectorXd kernelValues = qr.solve(b);
    if (qr.rank() < numColumns) {
      // A rank deficient system either has no solution or infinitely many.
      // Only the latter is underdetermined
      const double cost = 0.5 * (a * kernelValues - b).squaredNorm();
      if (cost > solutionCostThreshold) {
        return std::unexpected{
            Error{
                ErrorType::NoSolution,
                "The linear system is inconsistent",
            },
        };
      }
      return std::unexpected{
          Error{
              ErrorType::UnderdeterminedSystem,
              "The system of equations does not have a unique solution. In a "
              "circuit this usually means a node is floating or ideal voltage "
              "sources form a loop",
          },
      };
    }
    for (Eigen::Index j = 0; j < numColumns; j++) {
      const auto& kernel = columns[j];
      auto value = kernel->invert(kernelValues(j));
      if (!value) {
        return std::unexpected{
            Error{
                ErrorType::NoSolution,
                "The solution of the linear system is outside the range of "
                "its substituted subexpressions",
            },
        };
      }
      *kernel->unknown = *value;
    }
  }

  // Match the cost ceres reports so solutions are comparable
  double cost = 0;
  for (const auto& expression : expressions) {
    const double residual = expression.evaluateAtCurrentValues(conditionMap);
    cost += 0.5 * residual * residual;
  }

  // The linear system doesn't encode the conditions, so penalize solutions
  // outside this partition the same way NonLinearPartitionSolver does: bound
  // each constraint to its side of zero and add the distance between it and
  // the condition's value to the cost. A hard check would reject solutions
  // that lie on a partition boundary but are off by round-off error
  for (const auto& [condition, isTrue] : conditionMap) {
    const double value = Expression::evaluateCondition(condition, conditionMap);
    const double constraint = isTrue ? std::max(value, 0.0)  //
                                     : std::min(value, 0.0);
    *condition->getConstraint() = constraint;
    const double residual = value - constraint;
    cost += 0.5 * residual * residual;
  }
  // Solving happens in place
  return Solution{expressions, std::move(conditionMap), cost};
}

HybridPartitionSolver::HybridPartitionSolver()
    : HybridPartitionSolver(std::make_unique<LinearPartitionSolver>(),
                            std::make_unique<NonLinearPartitionSolver>()) {}
HybridPartitionSolver::HybridPartitionSolver(
    std::unique_ptr<PartitionSolver> linearSolver,
    std::unique_ptr<PartitionSolver> nonLinearSolver)
    : linearSolver(std::move(linearSolver)),
      nonLinearSolver(std::move(nonLinearSolver)) {}

auto HybridPartitionSolver::Solve(
    const std::vector<Expression>& expressions,
    std::unordered_map<std::shared_ptr<const Condition>, bool> conditionMap)
    -> std::expected<Solution, Error> {
  if (isPartitionLinear(expressions, conditionMap)) {
    return linearSolver->Solve(expressions, std::move(conditionMap));
  }
  return nonLinearSolver->Solve(expressions, std::move(conditionMap));
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

Solver::Solver() : partitionSolver(std::make_unique<HybridPartitionSolver>()) {}
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
  // Reported instead of a generic error if no partition has a solution, since
  // it tells the user what is wrong with their circuit
  auto underdeterminedError = std::optional<Error>{};
  for (uint32_t i = 0; i < numPartitions; i++) {
    conditionMaps.emplace_back();
    for (int j = 0; j < numConditions; j++) {
      auto bits = std::bitset<maxNumConditions>(i);
      conditionMaps.at(i)[orderedConditions.at(j)] = bits.test(j);
    }
    auto solution = partitionSolver->Solve(expressions, conditionMaps.at(i));
    if (solution.has_value()) {
      solutions.push_back(std::move(solution.value()));
    } else if (solution.error().type() == ErrorType::UnderdeterminedSystem &&
               !underdeterminedError) {
      underdeterminedError = solution.error();
    }
    resetUnknowns(expressions);
  }
  if (solutions.empty()) {
    if (underdeterminedError) {
      return std::unexpected{*underdeterminedError};
    }
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
    if (underdeterminedError) {
      return std::unexpected{*underdeterminedError};
    }
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
auto isPartitionLinear(const std::vector<Expression>& expressions,
                       ConditionMap conditionMap) -> bool {
  return expression::isLinear(expressions, conditionMap);
}
}  // namespace circuitsolver::solver
