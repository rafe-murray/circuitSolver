#ifndef SUBTRACTIONNODE_H
#define SUBTRACTIONNODE_H

#include "expressionNode.h"
#include <vector>

class SubtractionNode : public ExpressionNode {
public:
  SubtractionNode(ExpressionNode *lhs, ExpressionNode *rhs)
      : lhs(lhs), rhs(rhs) {}
  double compute(const vector<double> &values, const expressionMap &map) {
    value = lhs->compute(values, map) - rhs->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    lhs->gradient += gradient;
    lhs->updateChildrenGradient();
    rhs->gradient -= gradient;
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
