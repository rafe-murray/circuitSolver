#ifndef EXPONENTIATIONNODE_H
#define EXPONENTIATIONNODE_H
#include "expressionNode.h"
#include "multiplicationNode.h"
#include <math.h>
#include <memory>
#include <vector>

class ExponentiationNode : public ExpressionNode {
public:
  ExponentiationNode(shared_ptr<ExpressionNode> child) : child(child) {}
  double compute(const double* const values, const expressionMap& map) {
    value = std::exp(child->compute(values, map));
    return value;
  }
  void updateChildGradient() {
    child->gradient += value * gradient;
    child->updateChildrenGradient();
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    child->getUnknowns(unknowns);
  }
  void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "ExpressionNode (value=" << value << ")"
        << endl;
    child->print(out, indent + 1);
  }
  void serialize(ostream& out) const {
    out << "e^";
    child->serialize(out);
  }

private:
  shared_ptr<ExpressionNode> child;
};

#endif
