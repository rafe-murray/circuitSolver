#ifndef NEGATIONNODE_H
#define NEGATIONNODE_H

#include "expressionNode.h"
#include <vector>

class NegationNode : public ExpressionNode {
public:
  NegationNode(shared_ptr<ExpressionNode> child) : child(child) {}
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
  void print(ostream &out, int indent = 0) const {
    out << string(indent, ' ') << "NegationNode (value=" << value << ")"
        << endl;
    child->print(out, indent + 1);
  }

private:
  shared_ptr<ExpressionNode> child;
};

#endif
