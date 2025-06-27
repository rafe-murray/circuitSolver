#ifndef SUBTRACTIONNODE_H
#define SUBTRACTIONNODE_H

#include "expressionNode.h"
#include <vector>

class SubtractionNode : public ExpressionNode {
public:
  SubtractionNode(shared_ptr<ExpressionNode> lhs,
                  shared_ptr<ExpressionNode> rhs)
      : lhs(lhs), rhs(rhs) {}
  double compute(const double* const values, const expressionMap& map) {
    value = lhs->compute(values, map) - rhs->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    lhs->gradient += gradient;
    lhs->updateChildrenGradient();
    rhs->gradient -= gradient;
    rhs->updateChildrenGradient();
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    lhs->getUnknowns(unknowns);
    rhs->getUnknowns(unknowns);
  }
  void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "SubtractionNode (value=" << value << ")"
        << endl;
    lhs->print(out, indent + 1);
    rhs->print(out, indent + 1);
  }
  void serialize(ostream& out) const {
    out << "(";
    lhs->serialize(out);
    out << " - ";
    rhs->serialize(out);
    out << ")";
  }

private:
  shared_ptr<ExpressionNode> lhs;
  shared_ptr<ExpressionNode> rhs;
};

#endif
