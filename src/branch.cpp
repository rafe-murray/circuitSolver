#include "branch.h"

#include "circuitGraphMessage.pb.h"
#include "src/vertex.h"

Branch::Branch(const Vertex& from, const Vertex& to) : from(from), to(to) {}
Vertex Branch::getFrom() { return from; }
Vertex Branch::getTo() { return to; }
Expression Branch::getConstraint() const { return 0; }

void Branch::toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const {
  proto->set_fromid(from.getId());
  proto->set_toid(to.getId());
  proto->set_current(this->getCurrent().evaluate());
}

std::unique_ptr<Branch> CurrentSource::copy() const {
  return std::make_unique<CurrentSource>(*this);
}
CurrentSource::CurrentSource(const Vertex& from, const Vertex& to,
                             const Expression& current)
    : current(current), Branch(from, to) {}
Expression CurrentSource::getCurrent() const { return current; };
Expression CurrentSource::getConstraint() const {
  return from.getVoltage() + voltage - to.getVoltage();
}
void CurrentSource::toProto(
    circuitsolver::CircuitGraphMessage::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_currentsource()->set_voltage(voltage.evaluate());
}

std::unique_ptr<Branch> IdealDiode::copy() const {
  return std::make_unique<IdealDiode>(*this);
}
IdealDiode::IdealDiode(const Vertex& from, const Vertex& to,
                       const Expression& voltage, const Expression& current)
    : Branch(from, to),
      voltage(voltage),
      current(current),
      constraint(Expression::makeConditional(
          current > Expression(0.0), from.getVoltage() - to.getVoltage(),
          from.getVoltage() - to.getVoltage() + voltage)),
      conditionalCurrent(Expression::makeConditional(
          (from.getVoltage() - to.getVoltage()) < Expression(0.0),
          Expression(0.0), current)) {}
Expression IdealDiode::getCurrent() const { return conditionalCurrent; }
Expression IdealDiode::getConstraint() const { return constraint; }
void IdealDiode::toProto(
    circuitsolver::CircuitGraphMessage::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_idealdiode()->set_voltage(voltage.evaluate());
}

// TODO: change

std::unique_ptr<Branch> RealDiode::copy() const {
  return std::make_unique<RealDiode>(*this);
}
RealDiode::RealDiode(const Vertex& from, const Vertex& to, Expression i0,
                     Expression n, Expression vt)
    : Branch(from, to), i0(i0), vt(vt), n(n) {}
Expression RealDiode::getCurrent() const {
  return i0 * std::exp((from.getVoltage() - to.getVoltage()) / (n * vt));
}
void RealDiode::toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const {
  Branch::toProto(proto);
  auto protoRealDiode = proto->mutable_realdiode();
  protoRealDiode->set_i0(i0.evaluate());
  protoRealDiode->set_vt(vt.evaluate());
  protoRealDiode->set_n(n.evaluate());
}

std::unique_ptr<Branch> Resistor::copy() const {
  return std::make_unique<Resistor>(*this);
}
Resistor::Resistor(const Vertex& from, const Vertex& to,
                   const Expression& resistance)
    : resistance(resistance), Branch(from, to) {}
// The resistance of the resistor in the branch, in Ohms
Expression Resistor::getCurrent() const {
  return (from.getVoltage() - to.getVoltage()) / resistance;
}

void Resistor::toProto(circuitsolver::CircuitGraphMessage::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_resistor()->set_resistance(resistance.evaluate());
}

std::unique_ptr<Branch> VoltageSource::copy() const {
  return std::make_unique<VoltageSource>(*this);
}
VoltageSource::VoltageSource(const Vertex& from, const Vertex& to,
                             const Expression& voltage)
    : voltage(voltage), Branch(from, to) {}
// The voltage gain from the from to to, in Volts
Expression VoltageSource::getCurrent() const { return current; };
Expression VoltageSource::getConstraint() const {
  return from.getVoltage() + voltage - to.getVoltage();
}
void VoltageSource::toProto(
    circuitsolver::CircuitGraphMessage::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_voltagesource()->set_voltage(voltage.evaluate());
}

std::unique_ptr<Branch> ZenerDiode::copy() const {
  return std::make_unique<ZenerDiode>(*this);
}
ZenerDiode::ZenerDiode(const Vertex& from, const Vertex& to,
                       const Expression& izt, const Expression& rzt,
                       const Expression& vzt)
    : izt(izt), rzt(rzt), vzt(vzt), Branch(from, to) {}

Expression ZenerDiode::getCurrent() const {
  return (from.getVoltage() - to.getVoltage() + vzt - rzt * izt) / rzt;
}

void ZenerDiode::toProto(
    circuitsolver::CircuitGraphMessage::Edge* proto) const {
  Branch::toProto(proto);
  auto protoZenerDiode = proto->mutable_zenerdiode();
  protoZenerDiode->set_izt(izt.evaluate());
  protoZenerDiode->set_rzt(rzt.evaluate());
  protoZenerDiode->set_vzt(vzt.evaluate());
}
