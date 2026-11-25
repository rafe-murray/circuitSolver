#include <gtest/gtest.h>

#include "circuit_solver/expression.h"
#include "utils.h"

using circuitsolver::expression::Expression;
using circuitsolver::expression::getDefaultOptions;

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
  Expression c = circuitsolver::expression::exp(-y - 2.40797) - z;
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

TEST(MathTest, LinearExpressions) {
  using circuitsolver::expression::isLinear;
  Expression x, y;
  EXPECT_TRUE((x * 2 + y / 4 - 3).isLinear({}));
  EXPECT_TRUE((x + Expression(1) / (Expression(1) + Expression(1) / y))
                  .isLinear({}));
  // Kernels that are affine functions of each other are the same kernel
  EXPECT_TRUE(isLinear({x + Expression(1) / y, x - Expression(2) / y}, {}));
  EXPECT_TRUE(isLinear({Expression(1) / (Expression(1) / x) + y, x - y}, {}));
  EXPECT_FALSE((x * y).isLinear({}));
  EXPECT_FALSE((x / y).isLinear({}));
  EXPECT_FALSE((Expression(1) / (x + y)).isLinear({}));
  EXPECT_FALSE((y + Expression(1) / y).isLinear({}));
  EXPECT_FALSE(isLinear({x + y, Expression(1) / y}, {}));
  EXPECT_FALSE(isLinear({circuitsolver::expression::exp(x), x}, {}));
}

TEST(MathTest, LinearExpressionsWithConditions) {
  Expression x, y;
  auto condition = x < 0;
  Expression e = Expression::makeConditional(condition, x * y, x + y);
  auto conditions = e.getConditions();
  ASSERT_EQ(conditions.size(), 1);
  const auto& ptr = *conditions.begin();
  EXPECT_FALSE(e.isLinear({{ptr, true}}));
  EXPECT_TRUE(e.isLinear({{ptr, false}}));
}

TEST(MathTest, LinearizeRecordsKernels) {
  Expression x, y;
  auto system = circuitsolver::expression::linearize(
      {x + Expression(2) / (Expression(1) + Expression(1) / y) - 3}, {});
  ASSERT_TRUE(system.has_value());
  ASSERT_EQ(system->rows.size(), 1);
  EXPECT_EQ(system->rows[0].constant, -3);
  EXPECT_EQ(system->kernels.size(), 2);
  const auto& yKernel = system->kernels.at(y.getPtrToUnknown());
  EXPECT_EQ(system->rows[0].coefficients.at(yKernel), 2);
  // z = 1 / (1 + 1/y) = 0.75 => y = 3
  auto yValue = yKernel->invert(0.75);
  ASSERT_TRUE(yValue.has_value());
  EXPECT_TRUE(IsWithinRelativeTolerance(3, *yValue));
}
