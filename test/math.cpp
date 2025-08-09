#include "circuitsolver/math/expression.h"
#include "circuitsolver/math/expressionNode.h"
#include "circuitsolver/math/variable.h"
#include <gtest/gtest.h>
TEST(MathTest, BasicEquality) {
  Expression zero = 0;
  EXPECT_EQ(zero.getValue(), 0);
  Expression one(1);
  EXPECT_EQ(one.getValue(), 1);
  Expression x;
  Expression y = x;
  EXPECT_EQ(x.getValue(), y.getValue());
  Expression a = 1;
  Expression b(a);
  EXPECT_EQ(b.getValue(), 1);
}
// TODO: make assignment to a constant for expressions change the underlying
// expressionNode to a known VariableNode
TEST(MathTest, OneUnknown) {
  Expression x;
  Expression expressionWithUnknown = x * 3 + 1;
  x = 2;
  EXPECT_EQ(x.getValue(), 2);
  expressionWithUnknown.root->compute(nullptr, expressionMap());
  EXPECT_EQ(x.getValue() * 3 + 1, expressionWithUnknown.getValue());
}

TEST(MathTest, SharedUnknown) {
  Expression x;
  Expression e = x * 3 + 2;
  Expression f = x * x / 2 + 1;
  auto unknown = e.getUnknownVals();
  ASSERT_EQ(unknown.size(), 1);
  x = 3.0;
  e.root->compute(nullptr, expressionMap());
  f.root->compute(nullptr, expressionMap());
  EXPECT_EQ(e.getValue(), 11);
  EXPECT_EQ(f.getValue(), 5.5);
  EXPECT_EQ(x, 3);
}

TEST(MathTest, Compute) {
  Expression x;
  Expression y = -x * 3 + 1;
}
