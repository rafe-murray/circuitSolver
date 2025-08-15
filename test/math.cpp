#include "circuitsolver/expression.h"
#include <gtest/gtest.h>
#include <iostream>

// NOTE: falls back to absolute tolerance if expected == 0.0
testing::AssertionResult WithinRelativeTolerance(double expected, double actual,
                                                 double tol) {
  bool succeeded;
  if (expected == 0) {
    succeeded = fabs(expected - actual) <= tol;
  } else {
    succeeded = fabs(expected - actual) / fabs(expected) <= tol;
  }
  if (succeeded) {
    return testing::AssertionSuccess();
  } else {
    return testing::AssertionFailure()
           << "Expected " << expected << " but got " << actual
           << " which was not within the relative tolerance of " << tol;
  }
}

TEST(MathTest, BasicEquality) {
  Expression zero = 0;
  EXPECT_EQ(zero.evaluate(), 0);
  Expression one(1);
  EXPECT_EQ(one.evaluate(), 1);
  Expression x;
  Expression y = x;
  EXPECT_EQ(x.evaluate(), y.evaluate());
  EXPECT_EQ(x, y);
  Expression a = 1;
  Expression b(a);
  EXPECT_EQ(b, 1);
}
TEST(MathTest, OneUnknown) {
  Expression x;
  Expression expressionWithUnknown = x * 3 + 1;
  x = 2;
  EXPECT_EQ(x, 2);
  EXPECT_EQ(x * 3 + 1, expressionWithUnknown.evaluate());
}

TEST(MathTest, SharedUnknown) {
  Expression x;
  Expression e = x * 3 + 2;
  Expression f = x * x / 2 + 1;
  ASSERT_EQ(e.getNumUnknowns(), 1);
  x = 3.0;
  EXPECT_EQ(e.evaluate(), 11);
  EXPECT_EQ(f.evaluate(), 5.5);
  EXPECT_EQ(x.evaluate(), 3);
}

TEST(MathTest, CeresOptimization) {
  Expression x, y;
  Expression z = (x - 2) * (x - 2) + (y - 3) * (y - 3);
  ceres::Problem problem;
  z.addToProblem(problem);
  ceres::Solver::Options options = getDefaultOptions();
  ceres::Solver::Summary summary;
  ceres::Solve(options, &problem, &summary);
  ASSERT_TRUE(summary.IsSolutionUsable());
  z.markKnown();
  EXPECT_TRUE(WithinRelativeTolerance(0, z.evaluate(), 1e-4));
  EXPECT_TRUE(WithinRelativeTolerance(2, x.evaluate(), 1e-4));
  EXPECT_TRUE(WithinRelativeTolerance(3, y.evaluate(), 1e-4));
}

TEST(MathTest, CeresOptimizationLarge) {
  Expression x, y, z;
  Expression a = (-x + 1) * (y - x + 1) - 10;
  Expression b = y - x * y * y * 3 - 60;
  Expression c = std::exp(-y - 2.40797) - z;
  ceres::Problem problem;
  a.addToProblem(problem);
  b.addToProblem(problem);
  c.addToProblem(problem);
  ceres::Solver::Options options = getDefaultOptions();
  ceres::Solver::Summary summary;
  ceres::Solve(options, &problem, &summary);
  ASSERT_TRUE(summary.IsSolutionUsable());
  a.markKnown();
  b.markKnown();
  c.markKnown();
  EXPECT_TRUE(WithinRelativeTolerance(0, a.evaluate(), 1e-4));
  EXPECT_TRUE(WithinRelativeTolerance(0, b.evaluate(), 1e-4));
  EXPECT_TRUE(WithinRelativeTolerance(0, c.evaluate(), 1e-4));

  EXPECT_TRUE(WithinRelativeTolerance(-3.58771, x.evaluate(), 1e-4));
  EXPECT_TRUE(WithinRelativeTolerance(-2.40797, y.evaluate(), 1e-4));
  EXPECT_TRUE(WithinRelativeTolerance(1, z.evaluate(), 1e-4));
}
