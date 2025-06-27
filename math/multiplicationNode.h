#ifndef MULTIPLICATIONNODE_H
#define MULTIPLICATIONNODE_H

#include "expressionNode.h"
#include <memory>
#include <vector>

class MultiplicationNode : public ExpressionNode {
public:
  MultiplicationNode(shared_ptr<ExpressionNode> lhs,
                     shared_ptr<ExpressionNode> rhs)
      : lhs(lhs), rhs(rhs) {}
  double compute(const double* const values, const expressionMap& map) {
    value = lhs->compute(values, map) * rhs->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    lhs->gradient += rhs->value * gradient;
    lhs->updateChildrenGradient();
    rhs->gradient += lhs->value * gradient;
    rhs->updateChildrenGradient();
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    lhs->getUnknowns(unknowns);
    rhs->getUnknowns(unknowns);
  }
  void serialize(ostream& out) const {
    out << "(";
    lhs->serialize(out);
    out << " * ";
    rhs->serialize(out);
    out << ")";
  }

private:
  shared_ptr<ExpressionNode> lhs;
  shared_ptr<ExpressionNode> rhs;
};

#endif
