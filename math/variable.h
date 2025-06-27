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
#include <iostream>
#include <ostream>
#include <unordered_map>
#include <vector>

class VariableNode : public ExpressionNode {
public:
  bool known;
  VariableNode() : ExpressionNode(), known(false) {}
  VariableNode(double value) : ExpressionNode(value), known(true){};
  double compute(const double* const values, const expressionMap& map) {
    if (known) {
      return value;
    } else {
      return values[map.at(this)];
    }
  };
  void updateChildrenGradient() {}
  void getUnknowns(set<VariableNode*>& unknowns) {
    if (!known)
      unknowns.insert(this);
  }
  void print(ostream& out, int indent = 0) const {
    out << string(indent, ' ') << "VariableNode (value=" << value << ","
        << "known=" << known << ")" << endl;
  }
  void serialize(ostream& out) const {
    if (known) {
      out << value;
    } else {
      out << "Unknown @" << this;
    }
  }
};

namespace std {
template <> struct hash<VariableNode> {
  size_t operator()(const VariableNode&& v) const {
    hash<const VariableNode*> pointerHash;
    return pointerHash(&v);
  }
};
}; // namespace std

#endif
