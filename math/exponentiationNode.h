#ifndef EXPONENTIATIONNODE_H
#define EXPONENTIATIONNODE_H
#include "expressionNode.h"
#include "multiplicationNode.h"
#include <math.h>
#include <vector>

class ExponentiationNode : public ExpressionNode {
public:
  ExponentiationNode(ExpressionNode *child) : child(child) {}
  double compute(const vector<double> &values, const expressionMap &map) {
    value = std::exp(child->compute(values, map));
    return value;
  }
  void updateChildGradient() {
    child->gradient += value * gradient;
    child->updateChildrenGradient();
  }
  void getUnknowns(set<const Variable *> &unknowns) const {
    child->getUnknowns(unknowns);
  }

private:
  ExpressionNode *child;
};

#endif
