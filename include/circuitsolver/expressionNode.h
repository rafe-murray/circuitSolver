#ifndef EXPRESSIONNODE_H
#define EXPRESSIONNODE_H

#include <cmath>
#include <memory>
#include <ostream>
#include <unordered_map>
#include <unordered_set>

class BinaryOpNode;
class ExpressionNode;
class TernaryOpNode;
class UnaryOpNode;
class VariableNode;

typedef std::unordered_map<const double*, size_t> ExpressionMap;
typedef std::shared_ptr<ExpressionNode> ExpressionNodePtr;

/**
 * A single node in the AST of an `Expression`
 */
struct ExpressionNode {
  /**
   * virtual destructor to enable dynamic dispatch
   */
  virtual ~ExpressionNode() {}

  /**
   * Stores pointers to all unknown values in the AST with `this` as a root in
   * `unknowns`
   * @param unknowns a set of unknown values to add the unknowns in this AST to.
   * Unknowns in this AST may or may not be already present already;
   */
  virtual void
  getUnknowns(std::unordered_set<const double*>& unknowns) const = 0;

  // TODO: move all of these to friend declarations with implementations in the
  // source file That way it will actually print - currently it is a node on the
  // lhs
  /**
   * Prints the node to `out`
   * @param out the stream to print to
   * @return `out`
   */
  virtual std::ostream& operator<<(std::ostream& out) const = 0;
};

/**
 * Types of binary operations
 */
enum class BinaryOp { MUL, DIV, ADD, SUB };

/**
 * A Binary operation node in the AST
 */
struct BinaryOpNode : ExpressionNode {

  /**
   * Creates a `BinaryOpNode`
   * @param lhs the left hand side of the operation
   * @param rhs the right hand side of the operation
   * @param op the type of operation
   */
  BinaryOpNode(ExpressionNodePtr lhs, ExpressionNodePtr rhs, BinaryOp op);

  /**
   * Evaluates this node in the AST
   * @param parameters an array of values to be used for the unknowns
   * @param map a mapping from pointers to the unknown values to the index of
   * the corresponding value to use in `parameters`
   * @return the value of the AST with `this` as a root
   */
  template <typename T>
  T evaluateImplementation(T const* parameters,
                           const ExpressionMap& map) const {
    switch (op) {
    case BinaryOp::MUL:
      return evaluate(lhs, parameters, map) * evaluate(rhs, parameters, map);
    case BinaryOp::DIV:
      return evaluate(lhs, parameters, map) / evaluate(rhs, parameters, map);
    case BinaryOp::ADD:
      return evaluate(lhs, parameters, map) + evaluate(rhs, parameters, map);
    case BinaryOp::SUB:
      return evaluate(lhs, parameters, map) - evaluate(rhs, parameters, map);
    }
  }

  /**
   * @inheritdoc
   */
  void getUnknowns(std::unordered_set<const double*>& unknowns) const override;

  /**
   * @inheritdoc
   */
  std::ostream& operator<<(std::ostream& out) const override;

  /**
   * The left hand side of the operation
   */
  ExpressionNodePtr lhs;

  /**
   * The right hand side of the operation
   */
  ExpressionNodePtr rhs;

  /**
   * The type of operation
   */
  BinaryOp op;
};

/**
 * Types of binary operations that return booleans
 */
enum class BooleanBinaryOp { LT, LEQ, EQ, NEQ, GEQ, GT };

/**
 * A Binary operation node in the AST that return a boolean value.
 * Note that all other nodes return `double` values
 */
struct Condition {

  /**
   * Creates a `Condition`
   * @param lhs the left hand side of the operation
   * @param rhs the right hand side of the operation
   * @param op the type of operation
   */
  Condition(ExpressionNodePtr lhs, ExpressionNodePtr rhs, BooleanBinaryOp op);

  /**
   * Evaluates the AST with `this` as a root.
   * Note that this is templated so that `ceres` can do automatic
   * differentiation
   * @param parameters an array of values to be used for the unknowns
   * @param map a mapping from pointers to the unknown values to the index of
   * the corresponding value to use in `parameters`
   * @return the value of the AST with `this` as a root
   */
  template <typename T>
  bool evaluate(T const* parameters, const ExpressionMap& map) const {
    switch (op) {
    case BooleanBinaryOp::EQ:
      return evaluate(lhs, parameters, map) == evaluate(rhs, parameters, map);
    case BooleanBinaryOp::GEQ:
      return evaluate(lhs, parameters, map) >= evaluate(rhs, parameters, map);
    case BooleanBinaryOp::LEQ:
      return evaluate(lhs, parameters, map) <= evaluate(rhs, parameters, map);
    case BooleanBinaryOp::LT:
      return evaluate(lhs, parameters, map) < evaluate(rhs, parameters, map);
    case BooleanBinaryOp::GT:
      return evaluate(lhs, parameters, map) > evaluate(rhs, parameters, map);
    case BooleanBinaryOp::NEQ:
      return evaluate(lhs, parameters, map) != evaluate(rhs, parameters, map);
    }
  }

  /**
   * Stores pointers to all unknown values in the AST with `this` as a root in
   * `unknowns`
   * @param unknowns a set of unknown values to add the unknowns in this AST to.
   * Unknowns in this AST may or may not be already present already;
   */
  void getUnknowns(std::unordered_set<const double*>& unknowns) const;

  /**
   * Prints the node to `out`
   * @param out the stream to print to
   * @return `out`
   */
  std::ostream& operator<<(std::ostream& out) const;

  /**
   * The left hand side of the operation
   */
  ExpressionNodePtr lhs;

  /**
   * The right hand side of the operation
   */
  ExpressionNodePtr rhs;

  /**
   * The type of operation
   */
  BooleanBinaryOp op;
};

/**
 * A Ternary operation node in the AST
 */
struct TernaryOpNode : ExpressionNode {
  /*
   * Creates a `TernaryOpNode`
   * @param condition what to test to determine which expression to use
   * @param valIfTrue expression to use if `condition` is true
   * @param valIfFalse expression to use if `condition` is false
   */
  TernaryOpNode(std::shared_ptr<Condition> condition,
                ExpressionNodePtr valIfTrue, ExpressionNodePtr valIfFalse);

  /**
   * Evaluates this node in the AST
   * @param parameters an array of values to be used for the unknowns
   * @param map a mapping from pointers to the unknown values to the index of
   * the corresponding value to use in `parameters`
   * @return the value of the AST with `this` as a root
   */
  template <typename T>
  T evaluateImplementation(T const* parameters,
                           const ExpressionMap& map) const {
    if (condition->evaluate(parameters, map)) {
      return evaluate(valIfTrue, parameters, map);
    } else {
      return evaluate(valIfFalse, parameters, map);
    }
  }

  /**
   * @inheritdoc
   */
  void getUnknowns(std::unordered_set<const double*>& unknowns) const override;

  /**
   * @inheritdoc
   */
  std::ostream& operator<<(std::ostream& out) const override;

  /**
   * The condition used to determine which expression to evaluate
   */
  std::shared_ptr<Condition> condition;

  /**
   * The expression to evaluate if `condition` is true
   */
  ExpressionNodePtr valIfTrue;

  /**
   * The expression to evaluate if `condition` is false
   */
  ExpressionNodePtr valIfFalse;
};

/**
 * Types of unary operations
 */
enum class UnaryOp { EXP, NEG };

/**
 * A Unary operation node in the AST
 */
struct UnaryOpNode : ExpressionNode {

  /**
   * Creates a `UnaryOpNode`
   * @param operand the operand for the operation
   * @param op the type of operation
   */
  UnaryOpNode(ExpressionNodePtr operand, UnaryOp op);

  /**
   * Evaluates this node in the AST
   * @param parameters an array of values to be used for the unknowns
   * @param map a mapping from pointers to the unknown values to the index of
   * the corresponding value to use in `parameters`
   * @return the value of the AST with `this` as a root
   */
  template <typename T>
  T evaluateImplementation(T const* parameters,
                           const ExpressionMap& map) const {
    switch (op) {
    case UnaryOp::EXP:
      return std::exp(evaluate(operand, parameters, map));
    case UnaryOp::NEG:
      return -(evaluate(operand, parameters, map));
    }
  }

  /**
   * @inheritdoc
   */
  void getUnknowns(std::unordered_set<const double*>& unknowns) const override;

  /**
   * @inheritdoc
   */
  std::ostream& operator<<(std::ostream& out) const override;

  /**
   * The operand for the operation
   */
  ExpressionNodePtr operand;

  /**
   * The type of operation
   */
  UnaryOp op;
};

/**
 * A node representing a single known or unknown value in the AST
 */
struct VariableNode : ExpressionNode {
  /**
   * Creates a `VariableNode` representing an unknown
   */
  VariableNode();

  /**
   * Creates a `VariableNode` representing a known value
   * @param value the value of the node
   */
  VariableNode(double value);

  /**
   * Evaluates this node in the AST
   * @param parameters an array of values to be used for the unknowns
   * @param map a mapping from pointers to the unknown values to the index of
   * the corresponding value to use in `parameters`
   * @return the value of the AST with `this` as a root
   */
  template <typename T>
  T evaluateImplementation(T const* parameters,
                           const ExpressionMap& map) const {
    if (known) {
      return T(value);
    } else {
      return parameters[map.at(&value)];
    }
  }

  /**
   * @inheritdoc
   */
  void getUnknowns(std::unordered_set<const double*>& unknowns) const override;

  /**
   * @inheritdoc
   */
  std::ostream& operator<<(std::ostream& out) const override;

  /**
   * The value of this node
   */
  double value;

  /**
   * Is the value known or does this node represent an unknown
   */
  bool known;
};

/**
 * Evaluates the AST with `root` as a root.
 * Note that this is templated so that `ceres` can do automatic
 * differentiation
 * @param parameters an array of values to be used for the unknowns
 * @param map a mapping from pointers to the unknown values to the index of
 * the corresponding value to use in `parameters`
 * @return the value of the AST with `root` as a root
 */
template <typename T>
T evaluate(ExpressionNodePtr root, T const* parameters,
           const ExpressionMap& map) {
  ExpressionNode* ptr = root.get();
  if (auto node = dynamic_cast<const VariableNode*>(ptr)) {
    node->evaluateImplementation(parameters, map);
  }
  if (auto node = dynamic_cast<const BinaryOpNode*>(ptr)) {
    node->evaluateImplementation(parameters, map);
  }
  if (auto node = dynamic_cast<const UnaryOpNode*>(ptr)) {
    node->evaluateImplementation(parameters, map);
  }
  if (auto node = dynamic_cast<const TernaryOpNode*>(ptr)) {
    node->evaluateImplementation(parameters, map);
  }
}
#endif
