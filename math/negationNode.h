#ifndef NEGATIONNODE_H
#define NEGATIONNODE_H

#include "expressionNode.h"
#include <vector>

class NegationNode : public ExpressionNode {
public:
  NegationNode(ExpressionNode *child) : child(child) {}
  double compute(const vector<double> &values, const expressionMap &map) {
    value = -child->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    child->gradient -= gradient;
    child->updateChildrenGradient();
  }
  void getUnknowns(set<const Variable *> &unknowns) const {
    child->getUnknowns(unknowns);
  }

private:
  ExpressionNode *child;
};

#endif
