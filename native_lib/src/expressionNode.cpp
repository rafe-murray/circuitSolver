#include "circuit_solver/expressionNode.h"

#include <memory>
#include <ostream>
#include <unordered_set>
#include <utility>
#include <vector>

BinaryOpNode::BinaryOpNode(ExpressionNodePtr lhs, ExpressionNodePtr rhs,
                           BinaryOp op)
    : lhs(std::move(std::move(lhs))), rhs(std::move(std::move(rhs))), op(op) {}

Condition::Condition(const ExpressionNodePtr& lhs, const ExpressionNodePtr& rhs,
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

TernaryOpNode::TernaryOpNode(std::shared_ptr<const Condition> condition,
                             ExpressionNodePtr valIfTrue,
                             ExpressionNodePtr valIfFalse)
    : condition(std::move(std::move(condition))),
      valIfTrue(std::move(std::move(valIfTrue))),
      valIfFalse(std::move(std::move(valIfFalse))) {}
UnaryOpNode::UnaryOpNode(ExpressionNodePtr operand, UnaryOp op)
    : operand(std::move(std::move(operand))), op(op) {}

VariableNode::VariableNode() : value(1.0), known(false) {}
VariableNode::VariableNode(double value) : value(value), known(true) {}

void BinaryOpNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  lhs->getUnknowns(unknowns);
  rhs->getUnknowns(unknowns);
}

void Condition::getUnknowns(std::unordered_set<double*>& unknowns) const {
  val->getUnknowns(unknowns);
  constraint->getUnknowns(unknowns);
}

void TernaryOpNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  condition->getUnknowns(unknowns);
  valIfTrue->getUnknowns(unknowns);
  valIfFalse->getUnknowns(unknowns);
}

void UnaryOpNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  operand->getUnknowns(unknowns);
}

void VariableNode::getUnknowns(std::unordered_set<double*>& unknowns) {
  if (!known) {
    unknowns.insert(&value);
  }
}

void BinaryOpNode::markKnown() {
  lhs->markKnown();
  rhs->markKnown();
}

void Condition::markKnown() const {
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

auto BinaryOpNode::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  auto conditions = lhs->getConditions();
  conditions.merge(rhs->getConditions());
  return conditions;
}

auto Condition::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  auto conditions = std::unordered_set<std::shared_ptr<const Condition>>{
      shared_from_this(),
  };
  conditions.merge(val->getConditions());
  return conditions;
}

auto TernaryOpNode::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  auto conditions = condition->getConditions();
  conditions.merge(valIfTrue->getConditions());
  conditions.merge(valIfFalse->getConditions());
  return conditions;
}

auto UnaryOpNode::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  return operand->getConditions();
}

auto VariableNode::getConditions() const
    -> std::unordered_set<std::shared_ptr<const Condition>> {
  return {};
}

auto Condition::getError() const -> std::shared_ptr<BinaryOpNode> {
  return std::make_shared<BinaryOpNode>(val, constraint, BinaryOp::SUB);
}

auto BinaryOpNode::serialize(std::ostream& out) const -> std::ostream& {
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

auto operator<<(std::ostream& out, const Condition& condition)
    -> std::ostream& {
  out << "(" << condition.val << (condition.includeZero ? " >= " : " > ")
      << "0)";
  return out;
}

auto TernaryOpNode::serialize(std::ostream& out) const -> std::ostream& {
  out << "(" << *condition << " ? " << valIfTrue << " : " << valIfFalse << ")";
  return out;
}

auto UnaryOpNode::serialize(std::ostream& out) const -> std::ostream& {
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

auto VariableNode::serialize(std::ostream& out) const -> std::ostream& {
  if (known) {
    out << value;
  } else {
    out << &value;
  }
  return out;
}

auto operator<<(std::ostream& out, const ExpressionNodePtr& node)
    -> std::ostream& {
  return node->serialize(out);
}
