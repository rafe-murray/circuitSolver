#include "circuit_solver/expressionIterator.h"

#include <memory>
#include <utility>

#include "circuit_solver/expressionNode.h"
namespace circuitsolver::expression {
ExpressionIterator::ExpressionIterator(const ExpressionNodePtr& root) {
  if (root) {
    stack.push({.node = root});
    advance();
  }
}
auto ExpressionIterator::operator*() const -> reference { return current; }

auto ExpressionIterator::operator->() const -> pointer { return &current; }
auto ExpressionIterator::operator++() -> ExpressionIterator& {
  advance();
  return *this;
}
auto ExpressionIterator::operator++(int) -> ExpressionIterator {
  auto currThis = *this;
  advance();
  return currThis;
}
auto ExpressionIterator::operator==(const ExpressionIterator& other) const
    -> bool {
  return current == other.current;
}
void ExpressionIterator::advance() {
  auto insertIfNotVisited = [&](const ExpressionNodePtr& node) -> void {
    if (node != nullptr && !visited.contains(node)) {
      stack.push({.node = node});
    }
  };
  while (!stack.empty()) {
    // copy out of the stack so the frame stays valid across pushes/pops
    Frame f = std::move(stack.top());
    stack.pop();
    if (f.expanded) {  // all children already emitted
      current = std::move(f.node);
      return;
    }
    if (!visited.insert(f.node).second) {  // already handled via another parent
      continue;
    }
    ExpressionNodePtr node = f.node;
    // Re-push this node so it is emitted after its children
    stack.push({.node = std::move(f.node), .expanded = true});
    // Push children onto the stack
    switch (node->kind()) {
      case ExpressionNode::Kind::BinaryOp: {
        auto binOp = std::static_pointer_cast<BinaryOpNode>(node);
        insertIfNotVisited(binOp->lhs);
        insertIfNotVisited(binOp->rhs);
        break;
      }
      case ExpressionNode::Kind::TernaryOp: {
        auto ternOp = std::static_pointer_cast<TernaryOpNode>(node);
        insertIfNotVisited(ternOp->valIfTrue);
        insertIfNotVisited(ternOp->valIfFalse);
        insertIfNotVisited(ternOp->condition->val);
        insertIfNotVisited(ternOp->condition->constraint);
        break;
      }
      case ExpressionNode::Kind::UnaryOp: {
        auto unOp = std::static_pointer_cast<UnaryOpNode>(node);
        insertIfNotVisited(unOp->operand);
        break;
      }
      case ExpressionNode::Kind::Variable:
        break;
    }
  }
  // Stack is empty; we have reached the end
  current = nullptr;
}

}  // namespace circuitsolver::expression
