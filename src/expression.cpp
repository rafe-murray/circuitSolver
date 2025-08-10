#include "circuitsolver/expression.h"
#include "circuitsolver/expressionCostFunctor.h"
#include "circuitsolver/expressionNode.h"
#include <memory>
#include <ostream>
#include <stdexcept>
#include <unordered_set>

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

  shared_ptr<UnaryOpNode> n = dynamic_pointer_cast<UnaryOpNode>(rhs.root);
  if (n && n->op == UnaryOp::NEG)
    return Expression(
        make_shared<BinaryOpNode>(root, n->operand, BinaryOp::SUB));

  return Expression(make_shared<BinaryOpNode>(root, rhs.root, BinaryOp::ADD));
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

  return Expression(make_shared<BinaryOpNode>(root, rhs.root, BinaryOp::SUB));
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

  return Expression(make_shared<BinaryOpNode>(root, rhs.root, BinaryOp::MUL));
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

  return Expression(make_shared<BinaryOpNode>(root, rhs.root, BinaryOp::DIV));
}

Expression Expression::operator-() const {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    return Expression(-v->value);
  }
  return Expression(make_shared<UnaryOpNode>(root, UnaryOp::NEG));
}

Expression Expression::exp(const Expression& arg) {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(arg.root);
  if (v && v->known) {
    return Expression(std::exp(v->value));
  }
  return Expression(make_shared<UnaryOpNode>(arg.root, UnaryOp::EXP));
}

bool Expression::operator==(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(root);
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(rhs.root);
  // TODO: why has this been implemented this way?
  if (u && v && u->known && v->known) {
    /*cout << "Exressions had same value of " << u->value << endl;*/
    return u->value == v->value;
  }
  return root == rhs.root;
}

Expression& Expression::operator=(double rhs) {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v) {
    v->value = rhs;
    v->known = true;
  } else
    throw invalid_argument("Attempting to assign to an Expression that is "
                           "dependent on multiple unknowns");
  return *this;
}

Condition Expression::operator<(const Expression& rhs) const {
  return Condition(root, rhs.root, BooleanBinaryOp::LT);
}

Condition Expression::operator<=(const Expression& rhs) const {
  return Condition(root, rhs.root, BooleanBinaryOp::LEQ);
}
Condition Expression::operator>(const Expression& rhs) const {
  return Condition(root, rhs.root, BooleanBinaryOp::GT);
}
Condition Expression::operator>=(const Expression& rhs) const {
  return Condition(root, rhs.root, BooleanBinaryOp::GEQ);
}
Condition Expression::operator!=(const Expression& rhs) const {
  return Condition(root, rhs.root, BooleanBinaryOp::NEQ);
}
Condition Expression::equals(const Expression& rhs) const {
  return Condition(root, rhs.root, BooleanBinaryOp::EQ);
}
Expression Expression::makeConditional(Condition condition,
                                       const Expression& valIfTrue,
                                       const Expression& valIfFalse) {
  return Expression(
      make_shared<TernaryOpNode>(condition, valIfTrue.root, valIfFalse.root));
}

bool Expression::isConstant() const {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  return v && v->known;
}

std::unordered_set<const double*> Expression::getUnknowns() const {
  unordered_set<const double*> unknowns;
  this->root->getUnknowns(unknowns);
  return unknowns;
}

int Expression::getNumUnknowns() const { return getUnknowns().size(); }

ExpressionMap Expression::getMap() const {
  ExpressionMap map;
  unsigned i = 0;
  for (auto unknown : getUnknowns()) {
    (map)[unknown] = i;
    i++;
  }
  return map;
}

ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>
Expression::getCostFunction() {
  ExpressionMap map = getMap();
  ExpressionCostFunctor costFunctor(root, map);
  return ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>(
      &costFunctor);
}

double Expression::evaluate() const {
  double* parameters = new double[getNumUnknowns()];
  ExpressionMap map = getMap();
  return root->evaluate(parameters, map);
}

double Expression::evaluate(double const* parameters,
                            const ExpressionMap& map) const {
  return root->evaluate(parameters, map);
}

double* Expression::getPtrToUnknown() {
  std::shared_ptr<VariableNode> v =
      std::dynamic_pointer_cast<VariableNode>(root);
  if (v) {
    return &v->value;
  } else {
    return nullptr;
  }
}
