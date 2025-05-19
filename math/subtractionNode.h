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
  void getUnknowns(set<Variable*>& unknowns) {
    lhs->getUnknowns(unknowns);
    rhs->getUnknowns(unknowns);
  }
  void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "SubtractionNode (value=" << value << ")"
        << endl;
    lhs->print(out, indent + 1);
    rhs->print(out, indent + 1);
  }

private:
  shared_ptr<ExpressionNode> lhs;
  shared_ptr<ExpressionNode> rhs;
};

#endif
