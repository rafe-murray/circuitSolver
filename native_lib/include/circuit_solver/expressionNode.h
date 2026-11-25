#pragma once

#include <cstddef>
#include <cstdint>
#include <memory>
#include <ostream>
#include <span>
#include <unordered_map>

class BinaryOpNode;
class ExpressionNode;
class TernaryOpNode;
class UnaryOpNode;
class VariableNode;
class Condition;

// NOTE: if this class needs to have improved performance, we can do the
// following:
//  - Make all std::shared_ptr std::unique_ptr or raw pointers with a recursive
//    destructor for ExpressionNodes
//  - Switch double value in VariableNodes to std::shared_ptr<double> value
//  - That way we have many fewer reference counted pointers using atomic
//    operations while preserving the desired behaviour for unknowns

using ExpressionMap = std::unordered_map<const double*, size_t>;
using ExpressionNodePtr = std::shared_ptr<ExpressionNode>;
using ConditionMap = std::unordered_map<std::shared_ptr<const Condition>, bool>;

namespace expressionNode {
template <typename T>
auto evaluate(const ExpressionNodePtr& root, std::span<const T> parameters,
              const ExpressionMap& map, const ConditionMap& conditionMap) -> T;
}

/// A single node in the AST of an `Expression`
class ExpressionNode {
 public:
  enum class Kind : uint8_t {
    BinaryOp,
    TernaryOp,
    UnaryOp,
    Variable,
  };

  /// virtual destructor to enable dynamic dispatch
  virtual ~ExpressionNode() = default;

  /// Prints the node to `out`
  /// @param out the stream to print to
  /// @return `out`
  virtual auto serialize(std::ostream& out) const -> std::ostream& = 0;

  [[nodiscard]] virtual auto kind() const -> Kind = 0;

 protected:
  ExpressionNode() = default;
  ExpressionNode(const ExpressionNode& other) = default;
  auto operator=(const ExpressionNode& other) -> ExpressionNode& = default;
  ExpressionNode(ExpressionNode&& other) = default;
  auto operator=(ExpressionNode&& other) -> ExpressionNode& = default;
};

/// A Binary operation node in the AST
class BinaryOpNode : public ExpressionNode {
 public:
  /// Types of binary operations
  enum class Op : uint8_t { MUL, DIV, ADD, SUB };

  /// Creates a `BinaryOpNode`
  ///
  /// @param lhs the left hand side of the operation
  /// @param rhs the right hand side of the operation
  /// @param op the type of operation
  BinaryOpNode(ExpressionNodePtr lhs, ExpressionNodePtr rhs, Op op);

  auto serialize(std::ostream& out) const -> std::ostream& override;

  [[nodiscard]] auto kind() const -> Kind override;

  /// The left hand side of the operation
  ExpressionNodePtr lhs;

  /// The right hand side of the operation
  ExpressionNodePtr rhs;

  /// The type of operation
  Op op;
};

/// A Binary operation node in the AST that return a boolean value.
/// NOTE: all other nodes return `double` values
class Condition {
 public:
  /// Types of binary operations that return booleans
  enum class Op : uint8_t { LT, LEQ, GT, GEQ };

  /// Creates a `Condition`
  ///
  /// @param lhs the left hand side of the operation
  /// @param rhs the right hand side of the operation
  /// @param op the type of operation
  Condition(const ExpressionNodePtr& lhs, const ExpressionNodePtr& rhs, Op op);

  [[nodiscard]] auto getError() const -> std::shared_ptr<BinaryOpNode>;

  /// Gets the unknown that `getError` equates with the value of this condition.
  /// Bounding it during optimization bounds the value of this condition
  ///
  /// @return a pointer to the value of the unknown
  [[nodiscard]] auto getConstraint() const -> double*;

  /// Prints the node to `out`
  ///
  /// @param out the stream to print to
  /// @return `out`
  auto serialize(std::ostream& out) const -> std::ostream&;

  /// Value of the condition. The condition is true if this is greater than zero
  ExpressionNodePtr val;

  /// A variable node that should be equal in value to val. This allows us to
  /// put constraints on val during optimization
  std::shared_ptr<VariableNode> constraint;

  /// Whether to consider the condition true if val == 0
  bool includeZero;
  friend auto operator<<(std::ostream& out, const Condition& condition)
      -> std::ostream&;
};

/// A Ternary operation node in the AST
class TernaryOpNode : public ExpressionNode {
 public:
  /// Creates a `TernaryOpNode`
  ///
  /// @param condition what to test to determine which expression to use
  /// @param valIfTrue expression to use if `condition` is true
  /// @param valIfFalse expression to use if `condition` is false
  TernaryOpNode(std::shared_ptr<const Condition> condition,
                ExpressionNodePtr valIfTrue, ExpressionNodePtr valIfFalse);

  auto serialize(std::ostream& out) const -> std::ostream& override;

  /// The condition used to determine which expression to evaluate
  std::shared_ptr<const Condition> condition;

  [[nodiscard]] auto kind() const -> Kind override;

  /// The expression to evaluate if `condition` is true
  ExpressionNodePtr valIfTrue;

  /// The expression to evaluate if `condition` is false
  ExpressionNodePtr valIfFalse;
};

/// A Unary operation node in the AST
class UnaryOpNode : public ExpressionNode {
 public:
  /// Types of unary operations
  enum class Op : uint8_t { EXP, NEG };

  /// Creates a `UnaryOpNode`
  ///
  /// @param operand the operand for the operation
  /// @param op the type of operation
  UnaryOpNode(ExpressionNodePtr operand, Op op);

  auto serialize(std::ostream& out) const -> std::ostream& override;

  [[nodiscard]] auto kind() const -> Kind override;

  /// The operand for the operation
  ExpressionNodePtr operand;

  /// The type of operation
  Op op;
};

/// A node representing a single known or unknown value in the AST
class VariableNode : public ExpressionNode {
 public:
  /// Creates a `VariableNode` representing an unknown
  VariableNode();

  /// Creates a `VariableNode` representing a known value
  ///
  /// @param value the value of the node
  explicit VariableNode(double value);

  auto serialize(std::ostream& out) const -> std::ostream& override;

  [[nodiscard]] auto kind() const -> Kind override;

  /// The value of this node
  double value;

  /// Is the value known or does this node represent an unknown
  bool known;
};

auto operator<<(std::ostream& out, const ExpressionNodePtr& node)
    -> std::ostream&;
