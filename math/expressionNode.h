#ifndef EXPRESSIONNODE_H
#define EXPRESSIONNODE_H

#include <set>
#include <unordered_map>
#include <vector>

// FIXME remove after debugging
#include <ostream>

class AdditionNode;
class SubtractionNode;
class MultiplicationNode;
class DivisionNode;
class NegationNode;
class ExponentiationNode;
class Variable;

using namespace std;
typedef unordered_map<Variable*, unsigned> expressionMap;

// TODO: Test Expression class; see where it is going wrong.
// It might be necessary to switch the circuitGraph classes to using pointers
class ExpressionNode {
public:
  virtual ~ExpressionNode() {}
  ExpressionNode() : ExpressionNode(0.0) {}
  ExpressionNode(double value) : value(value), gradient(0.0) {}
  // TODO: fix this signature for all implementations of this
  virtual double compute(const double* const values, const expressionMap& map) {
    return 0.0;
  }
  virtual void getUnknowns(set<Variable*>& unknowns) {}
  virtual void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "ExpressionNode (value=" << value << ")"
        << endl;
  }

  virtual void updateChildrenGradient() {}
  double value;
  double gradient;
};

#endif
