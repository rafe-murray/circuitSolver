#include <ceres/solver.h>

#include <expected>
#include <memory>
#include <unordered_map>
#include <vector>

#include "circuit_solver/errors.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/expressionNode.h"
namespace circuitsolver::solver {

class Solution {
 public:
  Solution(const std::vector<Expression>& solvedExpressions,
           ConditionMap conditionMap, double cost);
  void apply() const;
  [[nodiscard]] auto getCost() const -> double;
  [[nodiscard]] auto getConditionMap() const -> ConditionMap;

 private:
  double cost;
  std::unordered_map<double*, double> unknownToValue;
  ConditionMap conditionMap;
};

class PartitionSolver {
 public:
  virtual ~PartitionSolver() = default;
  PartitionSolver() = default;
  PartitionSolver(const PartitionSolver&) = default;
  PartitionSolver(PartitionSolver&&) = delete;
  auto operator=(const PartitionSolver&) -> PartitionSolver& = default;
  auto operator=(PartitionSolver&&) -> PartitionSolver& = delete;

  virtual auto Solve(
      const std::vector<Expression>& expressions,
      std::unordered_map<std::shared_ptr<const Condition>, bool> conditionMap)
      -> std::expected<Solution, CircuitSolverError> = 0;
};

class NonLinearPartitionSolver : public PartitionSolver {
 public:
  NonLinearPartitionSolver();
  explicit NonLinearPartitionSolver(std::unique_ptr<ceres::Solver> ceresSolver);
  auto Solve(
      const std::vector<Expression>& expressions,
      std::unordered_map<std::shared_ptr<const Condition>, bool> conditionMap)
      -> std::expected<Solution, CircuitSolverError> override;

 private:
  std::unique_ptr<ceres::Solver> ceresSolver;
};

class Solver {
 public:
  Solver();
  explicit Solver(std::unique_ptr<PartitionSolver> partitionSolver);
  // PartitionSolver partitionSolver;
  auto Solve(const std::vector<Expression>& expressions)
      -> std::expected<Solution, CircuitSolverError>;

 private:
  std::unique_ptr<PartitionSolver> partitionSolver;
  static void resetUnknowns(const std::vector<Expression>& expressions);
};
}  // namespace circuitsolver::solver
