#ifndef MULTIPLICATIONNODE_H
#define MULTIPLICATIONNODE_H

#include "expressionNode.h"
#include <vector>

class MultiplicationNode : public ExpressionNode {
public:
  MultiplicationNode(ExpressionNode *lhs, ExpressionNode *rhs)
      : lhs(lhs), rhs(rhs) {}
  double compute(const vector<double> &values, const expressionMap &map) {
    value = lhs->compute(values, map) * rhs->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    lhs->gradient += rhs->value * gradient;
    lhs->updateChildrenGradient();
    rhs->gradient += lhs->value * gradient;
    rhs->updateChildrenGradient();
  }
  void getUnknowns(set<const Variable *> &unknowns) const {
    lhs->getUnknowns(unknowns);
    rhs->getUnknowns(unknowns);
  }

private:
  ExpressionNode *lhs;
  ExpressionNode *rhs;
};

#endif
