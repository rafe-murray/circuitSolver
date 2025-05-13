#ifndef EXPRESSIONNODE_H
#define EXPRESSIONNODE_H

#include <nlopt.hpp>
#include <set>
#include <unordered_map>
#include <vector>

class AdditionNode;
class SubtractionNode;
class MultiplicationNode;
class DivisionNode;
class NegationNode;
class ExponentiationNode;
class Variable;

using namespace std;
typedef unordered_map<Variable *, unsigned> expressionMap;

class ExpressionNode {
public:
  virtual double compute(const vector<double> &values,
                         const expressionMap &map) const;
  virtual void getUnknowns(set<const Variable *> &unknowns) const;

  virtual void updateChildrenGradient();
  double gradient;
  double value;
};

#endif
