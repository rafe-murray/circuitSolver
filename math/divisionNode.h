#ifndef DIVISIONNODE_H
#define DIVISIONNODE_H

#include "expressionNode.h"
#include <vector>

class DivisionNode : public ExpressionNode {
public:
  DivisionNode(ExpressionNode *lhs, ExpressionNode *rhs) : lhs(lhs), rhs(rhs) {}
  double compute(vector<double> values, expressionMap map) {
    value = lhs->compute(values, map) / rhs->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    lhs->gradient += (1.0 / rhs->value) * gradient;
    lhs->updateChildrenGradient();
    rhs->gradient += ((-lhs->value) / (rhs->value * rhs->value)) * gradient;
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
