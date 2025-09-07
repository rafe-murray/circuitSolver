#include <gtest/gtest.h>

#include "circuitGraphMessage.pb.h"

// NOTE: falls back to absolute tolerance if expected == 0.0
testing::AssertionResult IsWithinRelativeTolerance(double expected,
                                                   double actual,
                                                   double tol = 1e-4);

circuitsolver::CircuitGraphMessage GetMessageFromJsonFile(const char* filename);
