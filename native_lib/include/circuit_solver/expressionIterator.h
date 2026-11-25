#pragma once
#include <cstddef>
#include <iterator>
#include <stack>
#include <unordered_set>

#include "circuit_solver/expressionNode.h"

namespace circuitsolver::expression {
class ExpressionIterator {
 public:
  using iterator_category = std::forward_iterator_tag;
  using difference_type = std::ptrdiff_t;
  using value_type = ExpressionNodePtr;
  using pointer = const ExpressionNodePtr*;
  using reference = const ExpressionNodePtr&;
  ExpressionIterator() : current(nullptr) {}
  explicit ExpressionIterator(const ExpressionNodePtr& root);

  auto operator*() const -> reference;
  auto operator->() const -> pointer;

  auto operator++() -> ExpressionIterator&;

  auto operator++(int) -> ExpressionIterator;

  auto operator==(const ExpressionIterator& other) const -> bool;

 private:
  void advance();
  struct Frame {
    ExpressionNodePtr node;
    bool expanded = false;
  };
  std::stack<Frame> stack;
  std::unordered_set<ExpressionNodePtr> visited;
  ExpressionNodePtr current;
};
static_assert(std::forward_iterator<ExpressionIterator>);
}  // namespace circuitsolver::expression
