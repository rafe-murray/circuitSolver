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
  void print(ostream &out, int indent = 0) const {
    out << string(indent, ' ') << "MultiplicationNode (value=" << value << ")"
        << endl;
    lhs->print(out, indent + 1);
    rhs->print(out, indent + 1);
  }

private:
  shared_ptr<ExpressionNode> lhs;
  shared_ptr<ExpressionNode> rhs;
};

#endif
