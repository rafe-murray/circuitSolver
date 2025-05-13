#include "expression.h"
#include "additionNode.h"
#include "divisionNode.h"
#include "exponentiationNode.h"
#include "expressionNode.h"
#include "multiplicationNode.h"
#include "negationNode.h"
#include "subtractionNode.h"
#include "variable.h"

Expression::Expression() : Expression(new Variable(0)) {}
Expression Expression::operator+(const Expression &rhs) const {
  return Expression(new AdditionNode(root, rhs.root));
}
Expression Expression::operator-(const Expression &rhs) const {
  return Expression(new SubtractionNode(root, rhs.root));
}
Expression Expression::operator*(const Expression &rhs) const {
  return Expression(new MultiplicationNode(root, rhs.root));
}
Expression Expression::operator/(const Expression &rhs) const {
  return Expression(new DivisionNode(root, rhs.root));
}
Expression Expression::operator-() const {
  return Expression(new NegationNode(root));
}
Expression Expression::exp() const {
  return Expression(new ExponentiationNode(root));
}

set<const Variable *> Expression::getUnknowns() {
  set<const Variable *> unknowns;
  this->root->getUnknowns(unknowns);
  return unknowns;
}
expressionMap Expression::getMap() {
  expressionMap map;
  unsigned i = 0;
  for (auto unknown : getUnknowns()) {
    map[(Variable *)unknown] = i;
    i++;
  }
  return map;
}
void *Expression::getFunctionData() {
  expressionMap map = getMap();
  FunctionData *data = new FunctionData(this->root, map);
  return (void *)data;
}

nlopt::vfunc Expression::toFunction() {
  return [](const vector<double> &args, vector<double> &grad, void *ref) {
    FunctionData *data = (FunctionData *)ref;
    ExpressionNode *expression = data->expression;
    double returnVal = expression->compute(args, data->map);
    for (auto entry : data->map) {
      grad[entry.second] = entry.first->gradient;
    }
    return returnVal;
  };
}
