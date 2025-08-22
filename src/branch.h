#ifndef BRANCH_H
#define BRANCH_H

#include <memory>

#include "circuitGraphMessage.pb.h"
#include "expression.h"
#include "vertex.h"
// TODO: move the definitions to the source file not the header!!
class Branch {
 public:
  virtual ~Branch() {};
  virtual std::unique_ptr<Branch> copy() const = 0;
  Branch(const Vertex& from, const Vertex& to);
  Vertex getFrom();
  Vertex getTo();
  virtual Expression getCurrent() const = 0;
  virtual Expression getConstraint() const;
  virtual void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const;

 protected:
  const Vertex& from;
  const Vertex& to;
};

class CurrentSource : public Branch {
 public:
  std::unique_ptr<Branch> copy() const override;
  CurrentSource(const Vertex& from, const Vertex& to,
                const Expression& current);
  CurrentSource(const Vertex& from, const Vertex& to);
  Expression getCurrent() const override;
  Expression getConstraint() const override;
  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const override;

 private:
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
};
class IdealDiode : public Branch {
 public:
  std::unique_ptr<Branch> copy() const override;
  IdealDiode(const Vertex& from, const Vertex& to, const Expression& voltage,
             const Expression& current);

  Expression getCurrent() const override;
  Expression getConstraint() const override;
  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const override;

 private:
  Expression voltage;
  Expression current;
};

class RealDiode : public Branch {
 public:
  std::unique_ptr<Branch> copy() const override;
  RealDiode(const Vertex& from, const Vertex& to);
  RealDiode(const Vertex& from, const Vertex& to, Expression i0, Expression n,
            Expression vt);
  Expression getCurrent() const override;
  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const override;

 private:
  Expression i0;
  Expression vt;
  Expression n;
};

class Resistor : public Branch {
 public:
  std::unique_ptr<Branch> copy() const override;
  Resistor(const Vertex& from, const Vertex& to, const Expression& resistance);
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  Expression getCurrent() const override;

  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const override;
};

class VoltageSource : public Branch {
 public:
  std::unique_ptr<Branch> copy() const override;
  VoltageSource(const Vertex& from, const Vertex& to,
                const Expression& voltage);
  VoltageSource(const Vertex& from, const Vertex& to);
  // The voltage gain from the from to to, in Volts
  Expression voltage;
  Expression current;
  Expression getCurrent() const override;
  Expression getConstraint() const override;
  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const override;
};

class ZenerDiode : public Branch {
 public:
  std::unique_ptr<Branch> copy() const override;
  ZenerDiode(const Vertex& from, const Vertex& to, const Expression& izt,
             const Expression& rzt, const Expression& vzt);

  Expression getCurrent() const override;

  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const override;

 private:
  Expression izt, rzt, vzt;
};
#endif
