#include "expressionNode.h"

#include <memory>
#include <unordered_set>

BinaryOpNode::BinaryOpNode(ExpressionNodePtr lhs, ExpressionNodePtr rhs,
                           BinaryOp op)
    : lhs(lhs), rhs(rhs), op(op) {}

Condition::Condition(ExpressionNodePtr lhs, ExpressionNodePtr rhs,
                     BooleanBinaryOp op) {
  switch (op) {
    case BooleanBinaryOp::LT:
      val = std::make_shared<BinaryOpNode>(rhs, lhs, BinaryOp::SUB);
      includeZero = false;
      break;
    case BooleanBinaryOp::LEQ:
      val = std::make_shared<BinaryOpNode>(rhs, lhs, BinaryOp::SUB);
      includeZero = true;
      break;
    case BooleanBinaryOp::GEQ:
      val = std::make_shared<BinaryOpNode>(lhs, rhs, BinaryOp::SUB);
      includeZero = true;
      break;
    case BooleanBinaryOp::GT:
      val = std::make_shared<BinaryOpNode>(lhs, rhs, BinaryOp::SUB);
      includeZero = false;
      break;
  }
  constraint = std::make_shared<VariableNode>();
}

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
  val->getUnknowns(unknowns);
  constraint->getUnknowns(unknowns);
}

void Condition::getUnknowns(std::unordered_set<double*>& unknowns) {
  val->getUnknowns(unknowns);
  constraint->getUnknowns(unknowns);
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
  val->markKnown();
  constraint->markKnown();
}

void TernaryOpNode::markKnown() {
  condition->markKnown();
  valIfTrue->markKnown();
  valIfFalse->markKnown();
}

void UnaryOpNode::markKnown() { operand->markKnown(); }

void VariableNode::markKnown() { known = true; }

void BinaryOpNode::getDiscontinuities(
    std::unordered_set<double*>& discontinuities) {
  lhs->getDiscontinuities(discontinuities);
  rhs->getDiscontinuities(discontinuities);
}

void Condition::getDiscontinuities(
    std::unordered_set<double*>& discontinuities) {
  discontinuities.insert(&constraint->value);
  // Unlikely, but we could have nested conditionals, so we recurse
  val->getDiscontinuities(discontinuities);
}

void TernaryOpNode::getDiscontinuities(
    std::unordered_set<double*>& discontinuities) {
  condition->getDiscontinuities(discontinuities);
  valIfTrue->getDiscontinuities(discontinuities);
  valIfFalse->getDiscontinuities(discontinuities);
}

void UnaryOpNode::getDiscontinuities(
    std::unordered_set<double*>& discontinuities) {
  operand->getDiscontinuities(discontinuities);
}

void VariableNode::getDiscontinuities(
    std::unordered_set<double*>& discontinuities) {
  // Do nothing
}

void BinaryOpNode::getDiscontinuityError(
    std::vector<ExpressionNodePtr>& error) {
  lhs->getDiscontinuityError(error);
  rhs->getDiscontinuityError(error);
}

void Condition::getDiscontinuityError(std::vector<ExpressionNodePtr>& error) {
  error.push_back(getError());
  // Unlikely, but we could have nested conditionals, so we recurse
  val->getDiscontinuityError(error);
}

void TernaryOpNode::getDiscontinuityError(
    std::vector<ExpressionNodePtr>& error) {
  condition->getDiscontinuityError(error);
  valIfTrue->getDiscontinuityError(error);
  valIfFalse->getDiscontinuityError(error);
}

void UnaryOpNode::getDiscontinuityError(std::vector<ExpressionNodePtr>& error) {
  operand->getDiscontinuityError(error);
}

void VariableNode::getDiscontinuityError(
    std::vector<ExpressionNodePtr>& error) {
  // Do nothing
}

std::shared_ptr<BinaryOpNode> Condition::getError() const {
  return std::make_shared<BinaryOpNode>(val, constraint, BinaryOp::SUB);
}

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
  out << "(" << val << (includeZero ? " >= " : " > ") << "0)";
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
