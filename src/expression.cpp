#include "expression.h"

#include <iostream>
#include <memory>
#include <stdexcept>
#include <unordered_set>
#include <vector>

#include "expressionCostFunctor.h"
#include "expressionNode.h"

// TODO: remove this
using namespace std;

// TODO: add a scaling factor for each Expression
// - This way parameters can on the order of 1, which ceres expects
// - Still have accurate calculations
// - Apply the scaling factor when evaluating the Expression given a list of
// `double` parameters
// - We'd apply this manually given what type of answer we expect:
//  - 0.001 for resistors
//  - 1000 for currents
//  - 1 for voltages
//  - 1 by default

Expression::Expression() : Expression(make_shared<VariableNode>()) {}

Expression::Expression(double value)
    : Expression(make_shared<VariableNode>(value)) {}

Expression::Expression(shared_ptr<ExpressionNode> root)
    : root(std::move(root)) {}

Expression::~Expression() {}

Expression Expression::operator+(Expression rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 0) {
    return Expression(root);
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known && v->value == 0) {
    return Expression(std::move(rhs.root));
  }

  if (v && u && v->known && u->known) {
    return Expression(u->value + v->value);
  }

  shared_ptr<UnaryOpNode> n = dynamic_pointer_cast<UnaryOpNode>(rhs.root);
  if (n && n->op == UnaryOp::NEG)
    return Expression(
        make_shared<BinaryOpNode>(root, n->operand, BinaryOp::SUB));

  return Expression(
      make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::ADD));
}

Expression Expression::operator-(Expression rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known && u->value == 0) {
    return Expression(root);
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known && v->value == 0) {
    if (u && u->known) return Expression(-u->value);
    return -Expression(std::move(rhs.root));
  }

  if (v && u && v->known && u->known) {
    return Expression(v->value - u->value);
  }

  if (root == rhs.root) {
    return Expression(0.0);
  }

  return Expression(
      make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::SUB));
}

Expression Expression::operator*(Expression rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(rhs.root);
  if (u && u->known) {
    if (u->value == 0) {
      return Expression(std::move(rhs.root));
    } else if (u->value == 1) {
      return Expression(root);
    }
  }

  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    if (v->value == 0) {
      return Expression(root);
    } else if (v->value == 1) {
      return Expression(std::move(rhs.root));
    }
  }

  if (v && u && v->known && u->known) {
    return Expression(u->value * v->value);
  }

  return Expression(
      make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::MUL));
}

Expression Expression::operator/(Expression rhs) const {
  shared_ptr<VariableNode> u =
      dynamic_pointer_cast<VariableNode>(std::move(rhs.root));
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

  return Expression(
      make_shared<BinaryOpNode>(root, std::move(rhs.root), BinaryOp::DIV));
}

Expression Expression::operator-() const {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v && v->known) {
    return Expression(-v->value);
  }
  return Expression(make_shared<UnaryOpNode>(root, UnaryOp::NEG));
}

Expression std::exp(Expression arg) {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(arg.root);
  if (v && v->known) {
    return Expression(std::exp(v->value));
  }
  return Expression(
      make_shared<UnaryOpNode>(std::move(arg.root), UnaryOp::EXP));
}

bool Expression::operator==(const Expression& rhs) const {
  shared_ptr<VariableNode> u = dynamic_pointer_cast<VariableNode>(root);
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(rhs.root);
  // TODO: why has this been implemented this way?
  if (u && v && u->known && v->known) {
    return u->value == v->value;
  }
  return root == rhs.root;
}

bool Expression::operator==(double rhs) const {
  if (!isConstant()) {
    return false;
  }
  return evaluate() == rhs;
}

bool Expression::operator!=(const Expression& rhs) const {
  return !(*this == rhs);
}

Expression& Expression::operator=(double rhs) {
  shared_ptr<VariableNode> v = dynamic_pointer_cast<VariableNode>(root);
  if (v) {
    v->value = rhs;
    v->known = true;
  } else
    throw invalid_argument(
        "Attempting to assign to an Expression that is "
        "dependent on multiple unknowns");
  return *this;
}

Expression& Expression::operator+=(const Expression& rhs) {
  *this = *this + rhs;
  return *this;
}

Expression& Expression::operator-=(const Expression& rhs) {
  *this = *this - rhs;
  return *this;
}

Condition Expression::operator<(Expression rhs) const {
  return Condition(root, std::move(rhs.root), BooleanBinaryOp::LT);
}

Condition Expression::operator<=(Expression rhs) const {
  return Condition(root, std::move(rhs.root), BooleanBinaryOp::LEQ);
}
Condition Expression::operator>(Expression rhs) const {
  return Condition(root, std::move(rhs.root), BooleanBinaryOp::GT);
}
Condition Expression::operator>=(Expression rhs) const {
  return Condition(root, std::move(rhs.root), BooleanBinaryOp::GEQ);
}
// Condition Expression::operator!=(Expression rhs) const {
//   return Condition(root, std::move(rhs.root), BooleanBinaryOp::NEQ);
// }
// Condition Expression::equals(Expression rhs) const {
//   return Condition(root, std::move(rhs.root), BooleanBinaryOp::EQ);
// }
Expression Expression::makeConditional(Condition condition,
                                       Expression valIfTrue,
                                       Expression valIfFalse) {
  return Expression(make_shared<TernaryOpNode>(
      make_shared<Condition>(condition), std::move(valIfTrue.root),
      std::move(valIfFalse.root)));
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

std::vector<double*> Expression::getMutableUnknowns() {
  std::unordered_set<double*> unknownSet;
  root->getUnknowns(unknownSet);
  std::vector<double*> unknowns;
  unknowns.reserve(unknownSet.size());
  for (auto unknown : unknownSet) {
    unknowns.push_back(unknown);
  }
  return unknowns;
}

std::unordered_set<double*> Expression::getDiscontinuities() {
  std::unordered_set<double*> discontinuities;
  root->getDiscontinuities(discontinuities);
  return discontinuities;
}

std::vector<Expression> Expression::getDiscontinuityErrors() {
  std::vector<ExpressionNodePtr> errors;
  std::vector<Expression> errorExpressions;
  root->getDiscontinuityError(errors);
  for (auto error : errors) {
    errorExpressions.push_back(Expression(error));
  }
  return errorExpressions;
}

int Expression::getNumUnknowns() const { return getUnknowns().size(); }

ExpressionMap Expression::getMap() const {
  ExpressionMap map;
  unsigned i = 0;
  for (auto unknown : getUnknowns()) {
    map[unknown] = i;
    i++;
  }
  return map;
}

ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>*
Expression::getCostFunction() {
  ExpressionMap map = getMap();
  auto costFunctor = new ExpressionCostFunctor(root, map);
  return new ceres::DynamicAutoDiffCostFunction<ExpressionCostFunctor>(
      costFunctor);
}

void Expression::addToProblem(ceres::Problem& problem) {
  auto costFunction = getCostFunction();
  auto unknowns = getMutableUnknowns();
  for (int i = 0; i < unknowns.size(); i++) {
    costFunction->AddParameterBlock(1);
  }
  auto discontinuityErrors = getDiscontinuityErrors();
  for (auto error : discontinuityErrors) {
    error.addToProblem(problem);
  }
  costFunction->SetNumResiduals(1);
  problem.AddResidualBlock(costFunction, new ceres::HuberLoss(2.0), unknowns);
}

double Expression::evaluate() const {
  double* parameters = new double[getNumUnknowns()];
  ExpressionMap map = getMap();
  return expressionNode::evaluate(root, parameters, map);
}

double Expression::evaluate(double const* parameters) const {
  ExpressionMap map = getMap();
  return expressionNode::evaluate(root, parameters, map);
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

void Expression::markKnown() { root->markKnown(); }

std::ostream& operator<<(std::ostream& out, const Expression& e) {
  out << "(" << e.root.get() << ")" << e.root;
  return out;
}

ceres::Solver::Options getDefaultOptions() {
  ceres::Solver::Options options;

  options.linear_solver_type = ceres::DENSE_QR;
  options.minimizer_type = ceres::TRUST_REGION;
  options.trust_region_strategy_type = ceres::LEVENBERG_MARQUARDT;
  options.function_tolerance = 0;
  options.gradient_tolerance = 0;   // 1e-6
  options.parameter_tolerance = 0;  // 1e-6
  options.max_num_iterations = INT_MAX;
  // options.min_trust_region_radius = 1e-64;
  // NOTE: this parameter is VERY important - results in ~1500x better
  // performance
  options.use_nonmonotonic_steps = true;
  options.max_consecutive_nonmonotonic_steps = 10;
  return options;
}
