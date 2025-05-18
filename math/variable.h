#ifndef VARIABLE_H
#define VARIABLE_H

#include "additionNode.h"
#include "divisionNode.h"
#include "exponentiationNode.h"
#include "expression.h"
#include "expressionNode.h"
#include "multiplicationNode.h"
#include "negationNode.h"
#include "subtractionNode.h"
#include <unordered_map>
#include <vector>

class Variable : public ExpressionNode {
public:
  bool known;
  Variable() : known(false), ExpressionNode() {}
  Variable(double value) : known(true), ExpressionNode(value){};
  double compute(const vector<double> &values, const expressionMap &map) {
    return values[map.at(this)];
  };
  void updateChildrenGradient() {}
  void getUnknowns(set<const Variable *> &unknowns) const {
    if (!known)
      unknowns.insert(this);
  }
  void print(ostream &out, int indent = 0) const {
    out << string(indent, ' ') << "VariableNode (value=" << value << ","
        << "known=" << known << ")" << endl;
  }
};

namespace std {
template <> struct hash<Variable> {
  size_t operator()(const Variable &&v) const {
    hash<const Variable *> pointerHash;
    return pointerHash(&v);
  }
};
}; // namespace std

#endif
