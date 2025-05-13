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
  double value;
  bool known;
  Variable() : known(false){};
  Variable(double value) : value(value), known(true){};
  double compute(vector<double> values,
                 unordered_map<Variable *, unsigned> map) {
    return values[map[this]];
  };
  void updateChildrenGradient() {}
  void getUnknowns(set<const Variable *> &unknowns) const {
    if (!known)
      unknowns.insert(this);
  }
};

#endif
