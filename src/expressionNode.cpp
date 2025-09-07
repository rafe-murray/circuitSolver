#include "expressionNode.h"

#include <unordered_set>

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

VariableNode::VariableNode() : value(1.0), known(false) {}
VariableNode::VariableNode(double value) : value(value), known(true) {}

void BinaryOpNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void BinaryOpNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void Condition::getUnknowns(std::unordered_set<const double*>& unknowns) const {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void Condition::getUnknowns(std::unordered_set<double*>& unknowns) {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void TernaryOpNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  condition->getUnknowns(unknowns);
  valIfTrue->getUnknowns(unknowns);
  valIfFalse->getUnknowns(unknowns);
}

void TernaryOpNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  condition->getUnknowns(unknowns);
  valIfTrue->getUnknowns(unknowns);
  valIfFalse->getUnknowns(unknowns);
}

void UnaryOpNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  operand->getUnknowns(unknowns);
}

void UnaryOpNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  operand->getUnknowns(unknowns);
}

void VariableNode::getUnknowns(
    std::unordered_set<const double*>& unknowns) const {
  if (!known) unknowns.insert(&value);
}

void VariableNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  if (!known) unknowns.insert(&value);
}

void BinaryOpNode::markKnown() {
  lhs->markKnown();
  rhs->markKnown();
}

void Condition::markKnown() {
  lhs->markKnown();
  rhs->markKnown();
}

void TernaryOpNode::markKnown() {
  condition->markKnown();
  valIfTrue->markKnown();
  valIfFalse->markKnown();
}

void UnaryOpNode::markKnown() { operand->markKnown(); }

void VariableNode::markKnown() { known = true; }

std::ostream& BinaryOpNode::serialize(std::ostream& out) const {
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
  out << rhs << ")";
  return out;
}

std::ostream& Condition::serialize(std::ostream& out) const {
  out << "(" << lhs;
  switch (op) {
    // case BooleanBinaryOp::EQ:
    //   out << "==";
    //   break;
    // case BooleanBinaryOp::GEQ:
    //   out << ">=";
    //   break;
    // case BooleanBinaryOp::LEQ:
    //   out << "<=";
    //   break;
    case BooleanBinaryOp::GT:
      out << ">";
      break;
    case BooleanBinaryOp::LT:
      out << "<";
      break;
      // case BooleanBinaryOp::NEQ:
      //   out << "!=";
      //   break;
  }
  out << rhs << ")";
  return out;
}

std::ostream& TernaryOpNode::serialize(std::ostream& out) const {
  out << "(" << condition << " ? " << valIfTrue << " : " << valIfFalse << ")";
  return out;
}

std::ostream& UnaryOpNode::serialize(std::ostream& out) const {
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

std::ostream& VariableNode::serialize(std::ostream& out) const {
  if (known) {
    out << value;
  } else {
    out << this;
  }
  return out;
}

std::ostream& operator<<(std::ostream& out, ExpressionNodePtr node) {
  return node->serialize(out);
}
