#include "circuitsolver/expressionNode.h"

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
