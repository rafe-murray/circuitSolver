#pragma once

namespace circuitsolver::constants {
inline constexpr double huberLossDelta = 2.0;
inline constexpr double unknownSeedStdDeviation = 2.0;
inline constexpr double functionTolerance = 1e-6;
inline constexpr int maxIterations = 1000;
inline constexpr int maxConsecutiveNonMonotonicSteps = 10;
inline constexpr double solutionCostThreshold = 1e-15;
}  // namespace circuitsolver::constants
