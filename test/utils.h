#include <gtest/gtest.h>

// NOTE: falls back to absolute tolerance if expected == 0.0
testing::AssertionResult IsWithinRelativeTolerance(double expected,
                                                   double actual,
                                                   double tol = 1e-4);
