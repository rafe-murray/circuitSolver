#include "expression.h"
#include "additionNode.h"
#include "divisionNode.h"
#include "exponentiationNode.h"
#include "expressionCostFunction.h"
#include "expressionNode.h"
#include "multiplicationNode.h"
#include "negationNode.h"
#include "subtractionNode.h"
#include "variable.h"
#include <memory>

using namespace std;
Expression::Expression() : Expression(make_shared<Variable>()) {}
Expression::Expression(double value)
    : Expression(make_shared<Variable>(value)) {}
Expression::Expression(shared_ptr<ExpressionNode> root)
    : root(std::move(root)) {}
Expression::~Expression() {}
Expression Expression::operator+(const Expression& rhs) const {
  return Expression(make_shared<AdditionNode>(root, rhs.root));
}
Expression Expression::operator-(const Expression& rhs) const {
  return Expression(make_shared<SubtractionNode>(root, rhs.root));
}
Expression Expression::operator*(const Expression& rhs) const {
  return Expression(make_shared<MultiplicationNode>(root, rhs.root));
}
Expression Expression::operator/(const Expression& rhs) const {
  return Expression(make_shared<DivisionNode>(root, rhs.root));
}
Expression Expression::operator-() const {
  return Expression(make_shared<NegationNode>(root));
}
Expression Expression::exp() const {
  return Expression(make_shared<ExponentiationNode>(root));
}
bool Expression::operator==(const Expression& rhs) const {
  return root == rhs.root;
}

set<Variable*> Expression::getUnknowns() {
  set<Variable*> unknowns;
  this->root->getUnknowns(unknowns);
  return unknowns;
}
vector<double*> Expression::getUnknownVals() {
  set<Variable*> unknowns = getUnknowns();
  vector<double*> vals(unknowns.size());
  size_t i = 0;
  for (Variable* var : unknowns) {
    vals[i] = &var->value;
    i++;
  }
  return vals;
}
expressionMap* Expression::getMap() {
  expressionMap* map = new expressionMap();
  unsigned i = 0;
  for (auto unknown : getUnknowns()) {
    (*map)[(Variable*)unknown] = i;
    i++;
  }
  return map;
}
/*void* Expression::getFunctionData() {*/
/*  expressionMap map = getMap();*/
/*  FunctionData* data = new FunctionData(this->root, map);*/
/*  return (void*)data;*/
/*}*/

double Expression::getValue() { return root->value; }

/*nlopt::vfunc Expression::toFunction() {*/
/*  return [](const vector<double>& args, vector<double>& grad, void* ref) {*/
/*    FunctionData* data = (FunctionData*)ref;*/
/*    shared_ptr<ExpressionNode> expression = data->expression;*/
/*    double returnVal = expression->compute(args, data->map);*/
/*    if (!grad.empty()) {*/
/*      for (auto entry : data->map) {*/
/*        grad[entry.second] = entry.first->gradient;*/
/*      }*/
/*    }*/
/*    return returnVal;*/
/*  };*/
/*}*/
void Expression::print(std::ostream& out) const { root->print(out); }
ExpressionCostFunction* Expression::getCostFunction(int n) {
  expressionMap* map = getMap();
  return new ExpressionCostFunction(n, map, root);
}
