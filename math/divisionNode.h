#ifndef DIVISIONNODE_H
#define DIVISIONNODE_H

#include "expressionNode.h"
#include <memory>
#include <vector>

class DivisionNode : public ExpressionNode {
public:
  DivisionNode(shared_ptr<ExpressionNode> lhs, shared_ptr<ExpressionNode> rhs)
      : lhs(lhs), rhs(rhs) {}
  double compute(const double* const values, const expressionMap& map) {
    value = lhs->compute(values, map) / rhs->compute(values, map);
    return value;
  }
  void updateChildrenGradient() {
    lhs->gradient += (1.0 / rhs->value) * gradient;
    lhs->updateChildrenGradient();
    rhs->gradient += ((-lhs->value) / (rhs->value * rhs->value)) * gradient;
    rhs->updateChildrenGradient();
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    lhs->getUnknowns(unknowns);
    rhs->getUnknowns(unknowns);
  }
  void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "DivisionNode (value=" << value << ")"
        << endl;
    lhs->print(out, indent + 1);
    rhs->print(out, indent + 1);
  }
  void serialize(ostream& out) const {
    out << "(";
    lhs->serialize(out);
    out << " / ";
    rhs->serialize(out);
    out << ")";
  }

private:
  shared_ptr<ExpressionNode> lhs;
  shared_ptr<ExpressionNode> rhs;
};

#endif
