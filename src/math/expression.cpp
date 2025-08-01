#include "expression.h"
#include "additionNode.h"
#include "condition.h"
#include "conditionNode.h"
#include "divisionNode.h"
#include "exponentiationNode.h"
#include "expressionCostFunction.h"
#include "expressionNode.h"
#include "multiplicationNode.h"
#include "negationNode.h"
#include "subtractionNode.h"
#include "variable.h"
#include <memory>
#include <ostream>

using namespace std;

Expression::Expression() : Expression(make_shared<VariableNode>()) {}

Expression::Expression(double value)
    : Expression(make_shared<VariableNode>(value)) {}

Expression::Expression(shared_ptr<ExpressionNode> root)
    : root(std::move(root)) {}

Expression::~Expression() {}

Expression Expression::operator+(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 0) {
    return Expression(root);
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known && v->value == 0) {
    return Expression(rhs.root);
  }

  if (v && u && v->known && u->known) {
    return Expression(u->value + v->value);
  }

  shared_ptr<NegationNode> n = dynamic_pointer_cast<NegationNode>(rhs.root);
  if (n)
    return Expression(make_shared<SubtractionNode>(root, n->child));

  return Expression(make_shared<AdditionNode>(root, rhs.root));
}

Expression Expression::operator-(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 0) {
    return Expression(root);
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known && v->value == 0) {
    if (u && u->known)
      return Expression(-u->value);
    return -Expression(rhs.root);
  }

  if (v && u && v->known && u->known) {
    return Expression(v->value - u->value);
  }

  if (root == rhs.root) {
    return Expression(0.0);
  }

  return Expression(make_shared<SubtractionNode>(root, rhs.root));
}

Expression Expression::operator*(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known) {
    if (u->value == 0) {
      return Expression(rhs.root);
    } else if (u->value == 1) {
      return Expression(root);
    }
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    if (v->value == 0) {
      return Expression(root);
    } else if (v->value == 1) {
      return Expression(rhs.root);
    }
  }

  if (v && u && v->known && u->known) {
    return Expression(u->value * v->value);
  }

  return Expression(make_shared<MultiplicationNode>(root, rhs.root));
}

Expression Expression::operator/(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 1) {
    return Expression(root);
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);

  if (v && u && v->known && u->known) {
    return Expression(v->value / u->value);
  }

  if (root == rhs.root) {
    return Expression(1.0);
  }

  return Expression(make_shared<DivisionNode>(root, rhs.root));
}

Expression Expression::operator-() const {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    return Expression(-v->value);
  }
  return Expression(make_shared<NegationNode>(root));
}

Expression Expression::exp(const Expression& arg) {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(arg.root);
  if (v && v->known) {
    return Expression(std::exp(v->value));
  }
  return Expression(make_shared<ExponentiationNode>(arg.root));
}

bool Expression::operator==(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(root);
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && v && u->known && v->known) {
    /*cout << "Exressions had same value of " << u->value << endl;*/
    return u->value == v->value;
  }
  return root == rhs.root;
}

Condition Expression::operator<(const Expression& rhs) const {
  return Condition(ConditionType::LT, root, rhs.root);
}

Condition Expression::operator<=(const Expression& rhs) const {
  return Condition(ConditionType::LEQ, root, rhs.root);
}
Condition Expression::operator>(const Expression& rhs) const {
  return Condition(ConditionType::GT, root, rhs.root);
}
Condition Expression::operator>=(const Expression& rhs) const {
  return Condition(ConditionType::GEQ, root, rhs.root);
}
Condition Expression::operator!=(const Expression& rhs) const {
  return Condition(ConditionType::NEQ, root, rhs.root);
}
Condition Expression::equals(const Expression& rhs) const {
  return Condition(ConditionType::EQ, root, rhs.root);
}
Expression Expression::makeConditional(Condition condition,
                                       const Expression& valIfTrue,
                                       const Expression& valIfFalse) {
  return Expression(
      make_shared<ConditionNode>(condition, valIfTrue.root, valIfFalse.root));
}

bool Expression::isConstant() const {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  return v && v->known;
}

set<VariableNode*> Expression::getUnknowns() {
  set<VariableNode*> unknowns;
  this->root->getUnknowns(unknowns);
  return unknowns;
}
vector<double*> Expression::getUnknownVals() {
  set<VariableNode*> unknowns = getUnknowns();
  vector<double*> vals(unknowns.size());
  size_t i = 0;
  for (VariableNode* var : unknowns) {
    vals[i] = &var->value;
    i++;
  }
  return vals;
}
expressionMap* Expression::getMap() {
  expressionMap* map = new expressionMap();
  unsigned i = 0;
  for (auto unknown : getUnknowns()) {
    (*map)[(VariableNode*)unknown] = i;
    i++;
  }
  return map;
}

double Expression::getValue() const { return root->value; }

ostream& operator<<(ostream& out, const Expression& e) {
  e.root->serialize(out);
  return out;
}
ExpressionCostFunction* Expression::getCostFunction() {
  expressionMap* map = getMap();
  return new ExpressionCostFunction(map, root);
}
ostream& operator<<(ostream& out, const Condition& c) {
  string opString;
  switch (c.op) {
  case ConditionType::LT:
    opString = " < ";
    break;
  case ConditionType::LEQ:
    opString = " <= ";
    break;
  case ConditionType::EQ:
    opString = " == ";
    break;
  case ConditionType::NEQ:
    opString = " != ";
    break;
  case ConditionType::GEQ:
    opString = " >= ";
    break;
  case ConditionType::GT:
    opString = " > ";
    break;
  }
  out << "(";
  c.lhs->serialize(out);
  out << opString;
  c.rhs->serialize(out);
  out << ")";
  return out;
}
