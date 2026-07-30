#ifndef BRANCH_H
#define BRANCH_H

#include <memory>

#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"
// TODO: move the definitions to the source file not the header!!
class Branch {
 public:
  virtual ~Branch() = default;
  [[nodiscard]] virtual auto copy() const -> std::unique_ptr<Branch> = 0;
  Branch(const Vertex& from, const Vertex& to);
  auto getFrom() -> Vertex;
  auto getTo() -> Vertex;
  [[nodiscard]] virtual auto getCurrent() const -> Expression = 0;
  [[nodiscard]] virtual auto getConstraint() const -> Expression;
  virtual void toProto(proto::Edge* proto) const;
  virtual void toProto(proto::Edge* proto, const double* parameters) const;

 protected:
  const Vertex& from;
  const Vertex& to;
};

class CurrentSource : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  CurrentSource(const Vertex& from, const Vertex& to,
                const Expression& current = {});
  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto, const double* parameters) const override;

 private:
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
};
class IdealDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  IdealDiode(const Vertex& from, const Vertex& to,
             const Expression& voltage = {}, const Expression& current = {});

  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto, const double* parameters) const override;

 private:
  Expression voltage;
  Expression current;
  Expression constraint;
  Expression conditionalCurrent;
};

class RealDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  RealDiode(const Vertex& from, const Vertex& to, const Expression& i0 = {},
            const Expression& n = {}, const Expression& vt = {});
  auto getCurrent() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto, const double* parameters) const override;

 private:
  Expression i0;
  Expression vt;
  Expression n;
};

class Resistor : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  Resistor(const Vertex& from, const Vertex& to,
           const Expression& resistance = {});
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  auto getCurrent() const -> Expression override;

  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto, const double* parameters) const override;
};

class VoltageSource : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  VoltageSource(const Vertex& from, const Vertex& to,
                const Expression& voltage = {});
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
  auto getCurrent() const -> Expression override;
  auto getConstraint() const -> Expression override;
  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto, const double* parameters) const override;
};

class ZenerDiode : public Branch {
 public:
  auto copy() const -> std::unique_ptr<Branch> override;
  ZenerDiode(const Vertex& from, const Vertex& to, const Expression& izt = {},
             const Expression& rzt = {}, const Expression& vzt = {});

  auto getCurrent() const -> Expression override;

  void toProto(proto::Edge* proto) const override;
  void toProto(proto::Edge* proto, const double* parameters) const override;

 private:
  Expression izt, rzt, vzt;
};
#endif
