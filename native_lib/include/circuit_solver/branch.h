#ifndef BRANCH_H
#define BRANCH_H

#include <memory>

#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

struct BranchConnections {
  Vertex from;
  Vertex to;
};

/// A `Branch` contains the information specific to a particular kind of circuit
/// component
class Branch {
 public:
  virtual ~Branch() = default;
  /// Creates a copy of this `Branch`. This is needed when storing a `Branch`
  /// with a `std::unique_ptr`
  /// @return a copy of this `Branch`'s value
  [[nodiscard]] virtual auto copy() const -> std::unique_ptr<Branch> = 0;
  /// Get the `Vertex` this branch comes from (following the conventional
  /// current direction)
  auto getFrom() const -> Vertex;
  /// Get the `Vertex` this branch goes to (following the conventional current
  /// direction)
  auto getTo() const -> Vertex;
  /// Get the current through this branch
  [[nodiscard]] virtual auto getCurrent() const -> Expression = 0;

  // TODO: improve this description

  /// Get any additional constraints on this branch
  [[nodiscard]] virtual auto getConstraint() const -> Expression;
  /// Converts this branch to its protobuf representation
  ///
  /// @param proto the `proto::Edge` to add this `Branch`'s information to
  virtual void toProto(proto::Edge* proto) const;

 protected:
  /// Creates a new `Branch`
  explicit Branch(BranchConnections connections);
  /// Copies a `Branch`
  /// @param other the `Branch` to copy
  Branch(const Branch& other) = default;
  /// Copies a `Branch`
  /// @param other the `Branch` to copy
  auto operator=(const Branch& other) -> Branch& = default;
  /// Moves a `Branch`
  /// @param other the `Branch` to move
  Branch(Branch&& other) = default;
  /// Moves a `Branch`
  /// @param other the `Branch` to move
  auto operator=(Branch&& other) -> Branch& = default;

 private:
  /// The connections to `Vertex`es for this `Branch`
  BranchConnections connections;
};

/// A current source
class CurrentSource : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit CurrentSource(const BranchConnections& connections,
                         Expression current = {});
  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;

 private:
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
};

/// Parameters needed to define an ideal diode
struct IdealDiodeParameters {
  Expression voltage = {};
  Expression current = {};
};

/// An ideal diode
class IdealDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit IdealDiode(const BranchConnections& connections,
                      IdealDiodeParameters parameters = {});

  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;

 private:
  IdealDiodeParameters parameters;
  Expression constraint;
  Expression conditionalCurrent;
};

/// Parameters needed to define a real diode
struct RealDiodeParameters {
  Expression i0 = {};
  Expression n = {};
  Expression vt = {};
};

/// A real diode
class RealDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  RealDiode(const BranchConnections& connections,
            RealDiodeParameters parameters);
  auto getCurrent() const -> Expression override;
  void toProto(proto::Edge* proto) const override;

 private:
  RealDiodeParameters parameters;
};

/// A resistor
class Resistor : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit Resistor(const BranchConnections& connections,
                    Expression resistance = {});
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  auto getCurrent() const -> Expression override;

  void toProto(proto::Edge* proto) const override;
};

class VoltageSource : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit VoltageSource(const BranchConnections& connections,
                         Expression voltage = {});
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
};

/// Parameters needed to describe a Zener diode
struct ZenerDiodeParameters {
  Expression izt = {};
  Expression rzt = {};
  Expression vzt = {};
};

/// A Zener diode
class ZenerDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit ZenerDiode(BranchConnections connections,
                      ZenerDiodeParameters parameters = {});

  auto getCurrent() const -> Expression override;

  void toProto(proto::Edge* proto) const override;

 private:
  ZenerDiodeParameters parameters;
};
#endif
