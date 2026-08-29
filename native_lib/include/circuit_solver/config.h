#pragma once

namespace circuitsolver::constants {
/// Delta to use for Huber Loss Function
inline constexpr double huberLossDelta = 2.0;
/// Standard deviation to use when seeding unknowns
inline constexpr double unknownSeedStdDeviation = 2.0;
/// Function tolerance for numeric solver
inline constexpr double functionTolerance = 1e-6;
/// Maximum iterations for solver
inline constexpr int maxIterations = 1000;
/// Maximum non-monotonic steps
inline constexpr int maxConsecutiveNonMonotonicSteps = 10;
/// Cost threshold below which solutions are considered solved
inline constexpr double solutionCostThreshold = 1e-15;
}  // namespace circuitsolver::constants
