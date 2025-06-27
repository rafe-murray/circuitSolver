#ifndef NEGATIONNODE_H
#define NEGATIONNODE_H

#include "expressionNode.h"
#include <vector>

class NegationNode : public ExpressionNode {
public:
  NegationNode(shared_ptr<ExpressionNode> child) : child(child) {}
  double compute(const double* const values, const expressionMap& map) {
    value = -child->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    child->gradient -= gradient;
    child->updateChildrenGradient();
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    child->getUnknowns(unknowns);
  }
  void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "NegationNode (value=" << value << ")"
        << endl;
    child->print(out, indent + 1);
  }
  void serialize(ostream& out) const {
    out << "("
        << "-";
    child->serialize(out);
    out << ")";
  }

private:
  shared_ptr<ExpressionNode> child;
};

#endif
