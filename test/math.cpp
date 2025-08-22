#include <gtest/gtest.h>

#include "src/expression.h"
#include "utils.h"

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
  EXPECT_TRUE(IsWithinRelativeTolerance(0, z.evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(2, x.evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(3, y.evaluate()));
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
  EXPECT_TRUE(IsWithinRelativeTolerance(0, a.evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(0, b.evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(0, c.evaluate()));

  EXPECT_TRUE(IsWithinRelativeTolerance(-3.58771, x.evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(-2.40797, y.evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1, z.evaluate()));
}
