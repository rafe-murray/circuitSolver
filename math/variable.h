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
  operator Expression() { return Expression(this); }
  bool operator==(const Variable &rhs) const { return this == &rhs; }
  double value;
  bool known;
  Variable() : known(false){};
  Variable(double value) : value(value), known(true){};
  double compute(const vector<double> &values, const expressionMap &map) {
    return values[map.at(this)];
  };
  void updateChildrenGradient() {}
  void getUnknowns(set<const Variable *> &unknowns) const {
    if (!known)
      unknowns.insert(this);
  }
};

namespace std {
template <> struct hash<Variable> {
  size_t operator()(const Variable &v) const {
    hash<const Variable *> pointerHash;
    return pointerHash(&v);
  }
};
}; // namespace std

#endif
