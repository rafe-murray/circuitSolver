#ifndef CONDITIONNODE_H
#define CONDITIONNODE_H

#include "condition.h"
#include "expressionNode.h"
#include <memory>

class ConditionNode : public ExpressionNode {
public:
  ConditionNode(Condition condition, shared_ptr<ExpressionNode> valIfTrue,
                shared_ptr<ExpressionNode> valIfFalse)
      : condition(condition), valIfFalse(valIfFalse), valIfTrue(valIfTrue) {}

  double compute(const double* const values, const expressionMap& map) {
    return condition.compute(values, map) ? valIfTrue->compute(values, map)
                                          : valIfFalse->compute(values, map);
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    condition.getUnknowns(unknowns);
    valIfTrue->getUnknowns(unknowns);
    valIfFalse->getUnknowns(unknowns);
  }
  void print(ostream& out, int indent = 0) const {}

  // NOTE: this may not work with all optimization methods because it means the
  // gradient is not smooth
  void updateChildrenGradient() {
    condition.passed ? valIfTrue->updateChildrenGradient()
                     : valIfFalse->updateChildrenGradient();
  }

  void serialize(ostream& out) const {
    out << condition << " ? ";
    valIfTrue->serialize(out);
    out << " : ";
    valIfFalse->serialize(out);
  }

private:
  Condition condition;
  shared_ptr<ExpressionNode> valIfTrue;
  shared_ptr<ExpressionNode> valIfFalse;
};

#endif
