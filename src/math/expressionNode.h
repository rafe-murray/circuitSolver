#ifndef EXPRESSIONNODE_H
#define EXPRESSIONNODE_H

#include <set>
#include <unordered_map>

// FIXME remove after debugging
#include <ostream>

class AdditionNode;
class SubtractionNode;
class MultiplicationNode;
class DivisionNode;
class NegationNode;
class ExponentiationNode;
class VariableNode;

using namespace std;
typedef unordered_map<VariableNode*, size_t> expressionMap;

class ExpressionNode {
public:
  virtual ~ExpressionNode() {}
  ExpressionNode() : ExpressionNode(1.0) {}
  ExpressionNode(double value) : value(value), gradient(0.0) {}
  // TODO: fix this signature for all implementations of this
  virtual double compute(const double* const values, const expressionMap& map) {
    return 0.0;
  }
  virtual void getUnknowns(set<VariableNode*>& unknowns) {}
  virtual void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "ExpressionNode (value=" << value << ")"
        << endl;
  }
  virtual void serialize(ostream& out) const {}
  virtual void updateChildrenGradient() {}
  double value;
  double gradient;
};

#endif
