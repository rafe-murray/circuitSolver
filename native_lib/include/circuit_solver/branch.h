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

class Branch {
 public:
  virtual ~Branch() = default;
  [[nodiscard]] virtual auto copy() const -> std::unique_ptr<Branch> = 0;
  explicit Branch(BranchConnections connections);
  auto getFrom() const -> Vertex;
  auto getTo() const -> Vertex;
  [[nodiscard]] virtual auto getCurrent() const -> Expression = 0;
  [[nodiscard]] virtual auto getConstraint() const -> Expression;
  virtual void toProto(proto::Edge* proto) const;
  virtual void toProto(proto::Edge* proto,
                       std::span<const double> arguments) const;

 protected:
  Branch(const Branch& other) = default;
  auto operator=(const Branch& other) -> Branch& = default;
  Branch(Branch&& other) = default;
  auto operator=(Branch&& other) -> Branch& = default;

 private:
  BranchConnections connections;
};

class CurrentSource : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit CurrentSource(const BranchConnections& connections,
                         Expression current = {});
  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto,
               std::span<const double> arguments) const override;

 private:
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
};

struct IdealDiodeParameters {
  Expression voltage = {};
  Expression current = {};
};

class IdealDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit IdealDiode(const BranchConnections& connections,
                      IdealDiodeParameters parameters = {});

  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto,
               std::span<const double> arguments) const override;

 private:
  IdealDiodeParameters parameters;
  Expression constraint;
  Expression conditionalCurrent;
};

struct RealDiodeParameters {
  Expression i0 = {};
  Expression n = {};
  Expression vt = {};
};

class RealDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  RealDiode(const BranchConnections& connections,
            RealDiodeParameters parameters);
  auto getCurrent() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto,
               std::span<const double> arguments) const override;

 private:
  RealDiodeParameters parameters;
};

class Resistor : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit Resistor(const BranchConnections& connections,
                    Expression resistance = {});
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  auto getCurrent() const -> Expression override;

  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto,
               std::span<const double> arguments) const override;
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
  void toProto(proto::Edge* proto,
               std::span<const double> arguments) const override;
};

struct ZenerDiodeParameters {
  Expression izt = {};
  Expression rzt = {};
  Expression vzt = {};
};

class ZenerDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  explicit ZenerDiode(BranchConnections connections,
                      ZenerDiodeParameters parameters = {});

  auto getCurrent() const -> Expression override;

  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto,
               std::span<const double> arguments) const override;

 private:
  ZenerDiodeParameters parameters;
};
#endif
