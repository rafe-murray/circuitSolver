#include "circuitsolver/expressionNode.h"
#include <cmath>

BinaryOpNode::BinaryOpNode(ExpressionNodePtr lhs, ExpressionNodePtr rhs,
                           BinaryOp op)
    : lhs(lhs), rhs(rhs), op(op) {}

Condition::Condition(ExpressionNodePtr lhs, ExpressionNodePtr rhs,
                     BooleanBinaryOp op)
    : lhs(lhs), rhs(rhs), op(op) {}

TernaryOpNode::TernaryOpNode(std::shared_ptr<Condition> condition,
                             ExpressionNodePtr valIfTrue,
                             ExpressionNodePtr valIfFalse)
    : condition(condition), valIfTrue(valIfTrue), valIfFalse(valIfFalse) {}
UnaryOpNode::UnaryOpNode(ExpressionNodePtr operand, UnaryOp op)
    : operand(operand), op(op) {}

VariableNode::VariableNode() : value(), known(false) {}
VariableNode::VariableNode(double value) : value(value), known(true) {}

template <typename T>
T ExpressionNode::evaluate(T const* parameters,
                           const ExpressionMap& map) const {
  if (auto node = dynamic_cast<const VariableNode*>(this)) {
    node->evaluateImplementation(parameters, map);
  }
  if (auto node = dynamic_cast<const BinaryOpNode*>(this)) {
    node->evaluateImplementation(parameters, map);
  }
  if (auto node = dynamic_cast<const UnaryOpNode*>(this)) {
    node->evaluate(parameters, map);
  }
  if (auto node = dynamic_cast<const TernaryOpNode*>(this)) {
    node->evaluate(parameters, map);
  }
}

template <typename T>
T BinaryOpNode::evaluateImplementation(T const* parameters,
                                       const ExpressionMap& map) const {
  switch (op) {
  case BinaryOp::MUL:
    return lhs->evaluate(parameters, map) * rhs->evaluate(parameters, map);
  case BinaryOp::DIV:
    return lhs->evaluate(parameters, map) / rhs->evaluate(parameters, map);
  case BinaryOp::ADD:
    return lhs->evaluate(parameters, map) + rhs->evaluate(parameters, map);
  case BinaryOp::SUB:
    return lhs->evaluate(parameters, map) - rhs->evaluate(parameters, map);
  }
}

template <typename T>
bool Condition::evaluate(T const* parameters, const ExpressionMap& map) const {
  switch (op) {
  case BooleanBinaryOp::EQ:
    return lhs->evaluate(parameters, map) == rhs->evaluate(parameters, map);
  case BooleanBinaryOp::GEQ:
    return lhs->evaluate(parameters, map) >= rhs->evaluate(parameters, map);
  case BooleanBinaryOp::LEQ:
    return lhs->evaluate(parameters, map) <= rhs->evaluate(parameters, map);
  case BooleanBinaryOp::LT:
    return lhs->evaluate(parameters, map) < rhs->evaluate(parameters, map);
  case BooleanBinaryOp::GT:
    return lhs->evaluate(parameters, map) > rhs->evaluate(parameters, map);
  case BooleanBinaryOp::NEQ:
    return lhs->evaluate(parameters, map) != rhs->evaluate(parameters, map);
  }
}

template <typename T>
T TernaryOpNode::evaluateImplementation(T const* parameters,
                                        const ExpressionMap& map) const {
  if (condition->evaluate(parameters, map)) {
    return valIfTrue->evaluate(parameters, map);
  } else {
    return valIfFalse->evaluate(parameters, map);
  }
}

template <typename T>
T UnaryOpNode::evaluateImplementation(T const* parameters,
                                      const ExpressionMap& map) const {
  switch (op) {
  case UnaryOp::EXP:
    return std::exp(operand->evaluate(parameters, map));
  case UnaryOp::NEG:
    return -(operand->evaluate(parameters, map));
  }
}

template <typename T>
T VariableNode::evaluateImplementation(T const* parameters,
                                       const ExpressionMap& map) const {
  if (known) {
    return T(value);
  } else {
    return parameters[map.at(&value)];
  }
}

void BinaryOpNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void Condition::getUnknowns(std::unordered_set<const double*>& unknowns) const {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void TernaryOpNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  condition->getUnknowns(unknowns);
}

void UnaryOpNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  operand->getUnknowns(unknowns);
}

void VariableNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  unknowns.insert(&value);
}

std::ostream& BinaryOpNode::operator<<(std::ostream& out) const {
  out << "(" << lhs;
  switch (op) {
  case BinaryOp::MUL:
    out << " * ";
    break;
  case BinaryOp::DIV:
    out << " / ";
    break;
  case BinaryOp::ADD:
    out << " + ";
    break;
  case BinaryOp::SUB:
    out << " - ";
    break;
  }
  out << ")";
  return out;
}

std::ostream& Condition::operator<<(std::ostream& out) const {
  out << "(" << lhs;
  switch (op) {
  case BooleanBinaryOp::EQ:
    out << "==";
    break;
  case BooleanBinaryOp::GEQ:
    out << ">=";
    break;
  case BooleanBinaryOp::LEQ:
    out << "<=";
    break;
  case BooleanBinaryOp::GT:
    out << ">";
    break;
  case BooleanBinaryOp::LT:
    out << "<";
    break;
  case BooleanBinaryOp::NEQ:
    out << "!=";
    break;
  }
  out << ")";
  return out;
}

std::ostream& TernaryOpNode::operator<<(std::ostream& out) const {
  out << "(" << condition << " ? " << valIfTrue << " : " << valIfFalse << ")";
  return out;
}

std::ostream& UnaryOpNode::operator<<(std::ostream& out) const {
  out << "(";
  switch (op) {
  case UnaryOp::EXP:
    out << "e^";
    break;
  case UnaryOp::NEG:
    out << "-";
    break;
  }
  out << operand;
  return out;
}

std::ostream& VariableNode::operator<<(std::ostream& out) const {
  if (known) {
    out << value;
  } else {
    out << this;
  }
  return out;
}
