#ifndef EXPRESSIONNODE_H
#define EXPRESSIONNODE_H

#include <cstddef>
#include <cstdint>
#include <exception>
#include <memory>
#include <ostream>
#include <span>
#include <unordered_map>
#include <unordered_set>
#include <vector>

struct BinaryOpNode;
struct ExpressionNode;
struct TernaryOpNode;
struct UnaryOpNode;
struct VariableNode;
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
struct ExpressionNode {
  /// virtual destructor to enable dynamic dispatch
  virtual ~ExpressionNode() = default;

  /// Stores pointers to all unknown values in the AST with `this` as a root in
  /// `unknowns`
  ///
  /// @param unknowns a set of unknown values to add the unknowns in this AST
  /// to. Unknowns in this AST may or may not be already present already;
  virtual void getUnknowns(std::unordered_set<double*>& unknowns) = 0;

  /// Prints the node to `out`
  /// @param out the stream to print to
  /// @return `out`
  virtual auto serialize(std::ostream& out) const -> std::ostream& = 0;

  /// Marks the subtree of this node as known. This should be a no-op for node
  /// type that are not VariableNodes
  virtual void markKnown() = 0;

  // TODO: find a better name for discontinuities

  /// gets a list of conditions for this subtree
  [[nodiscard]] virtual auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>> = 0;

 protected:
  ExpressionNode() = default;
  ExpressionNode(const ExpressionNode& other) = default;
  auto operator=(const ExpressionNode& other) -> ExpressionNode& = default;
  ExpressionNode(ExpressionNode&& other) = default;
  auto operator=(ExpressionNode&& other) -> ExpressionNode& = default;
};

/// Types of binary operations
enum class BinaryOp : uint8_t { MUL, DIV, ADD, SUB };

/// A Binary operation node in the AST
struct BinaryOpNode : ExpressionNode {
  /// Creates a `BinaryOpNode`
  ///
  /// @param lhs the left hand side of the operation
  /// @param rhs the right hand side of the operation
  /// @param op the type of operation
  BinaryOpNode(ExpressionNodePtr lhs, ExpressionNodePtr rhs, BinaryOp op);

  /// Evaluates this node in the AST
  ///
  /// @param parameters an array of values to be used for the unknowns
  /// @param map a mapping from pointers to the unknown values to the index of
  /// the corresponding value to use in `parameters`
  /// @return the value of the AST with `this` as a root
  template <typename T>
  auto evaluateImplementation(std::span<T> parameters, const ExpressionMap& map,
                              const ConditionMap& conditionMap) const -> T {
    switch (op) {
      case BinaryOp::MUL:
        return expressionNode::evaluate(lhs, parameters, map, conditionMap) *
               expressionNode::evaluate(rhs, parameters, map, conditionMap);
      case BinaryOp::DIV:
        return expressionNode::evaluate(lhs, parameters, map, conditionMap) /
               expressionNode::evaluate(rhs, parameters, map, conditionMap);
      case BinaryOp::ADD:
        return expressionNode::evaluate(lhs, parameters, map, conditionMap) +
               expressionNode::evaluate(rhs, parameters, map, conditionMap);
      case BinaryOp::SUB:
        return expressionNode::evaluate(lhs, parameters, map, conditionMap) -
               expressionNode::evaluate(rhs, parameters, map, conditionMap);
    }
  }

  void getUnknowns(std::unordered_set<double*>& unknowns) override;

  auto serialize(std::ostream& out) const -> std::ostream& override;

  void markKnown() override;

  [[nodiscard]] auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>> override;

  /// The left hand side of the operation
  ExpressionNodePtr lhs;

  /// The right hand side of the operation
  ExpressionNodePtr rhs;

  /// The type of operation
  BinaryOp op;
};

/// Types of binary operations that return booleans
enum class BooleanBinaryOp : uint8_t { LT, LEQ, GT, GEQ };

/// A Binary operation node in the AST that return a boolean value.
/// NOTE: all other nodes return `double` values
class Condition : public std::enable_shared_from_this<Condition> {
 public:
  /// Creates a `Condition`
  ///
  /// @param lhs the left hand side of the operation
  /// @param rhs the right hand side of the operation
  /// @param op the type of operation
  Condition(const ExpressionNodePtr& lhs, const ExpressionNodePtr& rhs,
            BooleanBinaryOp op);

  [[nodiscard]] auto getError() const -> std::shared_ptr<BinaryOpNode>;

  /// Gets the unknown that `getError` equates with the value of this condition.
  /// Bounding it during optimization bounds the value of this condition
  ///
  /// @return a pointer to the value of the unknown
  [[nodiscard]] auto getConstraint() const -> double*;

  /// Stores pointers to all unknown values in the AST with `this` as a root in
  /// `unknowns`
  ///
  /// @param unknowns a set of unknown values to add the unknowns in this AST
  /// to. Unknowns in this AST may or may not be already present already;
  void getUnknowns(std::unordered_set<double*>& unknowns) const;

  /// Prints the node to `out`
  ///
  /// @param out the stream to print to
  /// @return `out`
  auto serialize(std::ostream& out) const -> std::ostream&;

  void markKnown() const;
  [[nodiscard]] auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>>;
  void getDiscontinuityError(std::vector<ExpressionNodePtr>& error) const;

 private:
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
struct TernaryOpNode : ExpressionNode {
  /// Creates a `TernaryOpNode`
  ///
  /// @param condition what to test to determine which expression to use
  /// @param valIfTrue expression to use if `condition` is true
  /// @param valIfFalse expression to use if `condition` is false
  TernaryOpNode(std::shared_ptr<const Condition> condition,
                ExpressionNodePtr valIfTrue, ExpressionNodePtr valIfFalse);

  /// Evaluates this node in the AST
  ///
  /// @param parameters an array of values to be used for the unknowns
  /// @param map a mapping from pointers to the unknown values to the index of
  /// the corresponding value to use in `parameters`
  /// @return the value of the AST with `this` as a root
  template <typename T>
  auto evaluateImplementation(std::span<T> parameters,
                              const ExpressionMap& expressionMap,
                              const ConditionMap& conditionMap) const -> T {
    return conditionMap.at(condition)
               ? expressionNode::evaluate(valIfTrue, parameters, expressionMap,
                                          conditionMap)
               : expressionNode::evaluate(valIfFalse, parameters, expressionMap,
                                          conditionMap);
  }

  void getUnknowns(std::unordered_set<double*>& unknowns) override;

  auto serialize(std::ostream& out) const -> std::ostream& override;

  /// The condition used to determine which expression to evaluate
  std::shared_ptr<const Condition> condition;

  void markKnown() override;

  [[nodiscard]] auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>> override;

  /// The expression to evaluate if `condition` is true
  ExpressionNodePtr valIfTrue;

  /// The expression to evaluate if `condition` is false
  ExpressionNodePtr valIfFalse;
};

/// Types of unary operations
enum class UnaryOp : uint8_t { EXP, NEG };

/// A Unary operation node in the AST
struct UnaryOpNode : ExpressionNode {
  /// Creates a `UnaryOpNode`
  ///
  /// @param operand the operand for the operation
  /// @param op the type of operation
  UnaryOpNode(ExpressionNodePtr operand, UnaryOp op);

  /// Evaluates this node in the AST
  ///
  /// @param parameters an array of values to be used for the unknowns
  /// @param map a mapping from pointers to the unknown values to the index of
  /// the corresponding value to use in `parameters`
  /// @return the value of the AST with `this` as a root
  template <typename T>
  auto evaluateImplementation(std::span<T> parameters, const ExpressionMap& map,
                              const ConditionMap& conditionMap) const -> T {
    switch (op) {
      case UnaryOp::EXP:
        return exp(
            expressionNode::evaluate(operand, parameters, map, conditionMap));
      case UnaryOp::NEG:
        return -(
            expressionNode::evaluate(operand, parameters, map, conditionMap));
    }
  }

  void getUnknowns(std::unordered_set<double*>& unknowns) override;

  auto serialize(std::ostream& out) const -> std::ostream& override;

  void markKnown() override;

  [[nodiscard]] auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>> override;

  /// The operand for the operation
  ExpressionNodePtr operand;

  /// The type of operation
  UnaryOp op;
};

/// A node representing a single known or unknown value in the AST
struct VariableNode : ExpressionNode {
  /// Creates a `VariableNode` representing an unknown
  VariableNode();

  /// Creates a `VariableNode` representing a known value
  ///
  /// @param value the value of the node
  explicit VariableNode(double value);

  /// Evaluates this node in the AST
  ///
  /// @param parameters an array of values to be used for the unknowns
  /// @param map a mapping from pointers to the unknown values to the index of
  /// the corresponding value to use in `parameters`
  /// @return the value of the AST with `this` as a root
  template <typename T>
  auto evaluateImplementation(std::span<T> parameters,
                              const ExpressionMap& map) const -> T {
    if (known) {
      return T(value);
    }
    return parameters[map.at(&value)];
  }

  void getUnknowns(std::unordered_set<double*>& unknowns) override;

  auto serialize(std::ostream& out) const -> std::ostream& override;

  void markKnown() override;

  [[nodiscard]] auto getConditions() const
      -> std::unordered_set<std::shared_ptr<const Condition>> override;

  /// The value of this node
  double value;

  /// Is the value known or does this node represent an unknown
  bool known;
};

namespace expressionNode {
class InvalidNodeTypeException : public std::exception {
  [[nodiscard]] auto what() const noexcept -> const char* override {
    return "Invalid ExpressionNode type. Valid types are VariableNode, "
           "BinaryOpNode, UnaryOpNode, and TernaryOpNode";
  }
};

// TODO: add a NodeType enum and use that instead of RTTI for evaluate since
// this is called very frequently

/// Evaluates the AST with `root` as a root.
///
/// Note that this is templated so that `ceres` can do automatic
/// differentiation
/// @param parameters an array of values to be used for the unknowns
/// @param map a mapping from pointers to the unknown values to the index of
/// the corresponding value to use in `parameters`
/// @return the value of the AST with `root` as a root
template <typename T>
auto evaluate(const ExpressionNodePtr& root, std::span<const T> parameters,
              const ExpressionMap& map, const ConditionMap& conditionMap) -> T {
  if (std::shared_ptr<VariableNode> node =
          std::dynamic_pointer_cast<VariableNode>(root)) {
    return node->evaluateImplementation(parameters, map);
  }
  if (std::shared_ptr<BinaryOpNode> node =
          std::dynamic_pointer_cast<BinaryOpNode>(root)) {
    return node->evaluateImplementation(parameters, map, conditionMap);
  }
  if (std::shared_ptr<UnaryOpNode> node =
          std::dynamic_pointer_cast<UnaryOpNode>(root)) {
    return node->evaluateImplementation(parameters, map, conditionMap);
  }
  if (std::shared_ptr<TernaryOpNode> node =
          std::dynamic_pointer_cast<TernaryOpNode>(root)) {
    return node->evaluateImplementation(parameters, map, conditionMap);
  }
  throw InvalidNodeTypeException{};
}
}  // namespace expressionNode

auto operator<<(std::ostream& out, const ExpressionNodePtr& node)
    -> std::ostream&;
#endif
