#include "circuit_solver/branch.h"

#include <uuid.h>

#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

Branch::Branch(const Vertex& from, const Vertex& to) : from(from), to(to) {}
auto Branch::getFrom() -> Vertex { return from; }
auto Branch::getTo() -> Vertex { return to; }
auto Branch::getConstraint() const -> Expression { return 0; }

void Branch::toProto(proto::Edge* proto) const {
  std::string fromId = uuids::to_string(from.getId());
  std::string toId = uuids::to_string(to.getId());
  proto->set_from_id(fromId);
  proto->set_to_id(toId);
  proto->set_current(this->getCurrent().evaluate());
}
void Branch::toProto(proto::Edge* proto, const double* parameters) const {
  std::string fromId = uuids::to_string(from.getId());
  std::string toId = uuids::to_string(to.getId());
  proto->set_from_id(fromId);
  proto->set_to_id(toId);
  proto->set_current(this->getCurrent().evaluate(parameters));
}

auto CurrentSource::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<CurrentSource>(*this);
}
CurrentSource::CurrentSource(const Vertex& from, const Vertex& to,
                             const Expression& current)
    : Branch(from, to), current(current) {}
auto CurrentSource::getCurrent() const -> Expression { return current; };
auto CurrentSource::getConstraint() const -> Expression {
  return from.getVoltage() + voltage - to.getVoltage();
}
void CurrentSource::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_current_source()->set_voltage(voltage.evaluate());
}
void CurrentSource::toProto(proto::Edge* proto,
                            const double* parameters) const {
  Branch::toProto(proto, parameters);
  proto->mutable_current_source()->set_voltage(voltage.evaluate(parameters));
}

auto IdealDiode::copy() const -> std::unique_ptr<Branch> {
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
auto IdealDiode::getCurrent() const -> Expression { return conditionalCurrent; }
auto IdealDiode::getConstraint() const -> Expression { return constraint; }
void IdealDiode::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_ideal_diode()->set_voltage(voltage.evaluate());
}
void IdealDiode::toProto(proto::Edge* proto, const double* parameters) const {
  Branch::toProto(proto, parameters);
  proto->mutable_ideal_diode()->set_voltage(voltage.evaluate(parameters));
}

// TODO: change

auto RealDiode::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<RealDiode>(*this);
}
RealDiode::RealDiode(const Vertex& from, const Vertex& to, const Expression& i0,
                     const Expression& n, const Expression& vt)
    : Branch(from, to), i0(i0), vt(vt), n(n) {}
auto RealDiode::getCurrent() const -> Expression {
  return i0 * std::exp((from.getVoltage() - to.getVoltage()) / (n * vt));
}
void RealDiode::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  auto* protoRealDiode = proto->mutable_real_diode();
  protoRealDiode->set_i0(i0.evaluate());
  protoRealDiode->set_vt(vt.evaluate());
  protoRealDiode->set_n(n.evaluate());
}
void RealDiode::toProto(proto::Edge* proto, const double* parameters) const {
  Branch::toProto(proto, parameters);
  auto* protoRealDiode = proto->mutable_real_diode();
  protoRealDiode->set_i0(i0.evaluate(parameters));
  protoRealDiode->set_vt(vt.evaluate(parameters));
  protoRealDiode->set_n(n.evaluate(parameters));
}

auto Resistor::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<Resistor>(*this);
}
Resistor::Resistor(const Vertex& from, const Vertex& to,
                   const Expression& resistance)
    : Branch(from, to), resistance(resistance) {}
// The resistance of the resistor in the branch, in Ohms
auto Resistor::getCurrent() const -> Expression {
  return (from.getVoltage() - to.getVoltage()) / resistance;
}

void Resistor::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_resistor()->set_resistance(resistance.evaluate());
}
void Resistor::toProto(proto::Edge* proto, const double* parameters) const {
  Branch::toProto(proto, parameters);
  proto->mutable_resistor()->set_resistance(resistance.evaluate(parameters));
}

auto VoltageSource::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<VoltageSource>(*this);
}
VoltageSource::VoltageSource(const Vertex& from, const Vertex& to,
                             const Expression& voltage)
    : Branch(from, to), voltage(voltage) {}
// The voltage gain from the from to to, in Volts
auto VoltageSource::getCurrent() const -> Expression { return current; };
auto VoltageSource::getConstraint() const -> Expression {
  return from.getVoltage() + voltage - to.getVoltage();
}
void VoltageSource::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_voltage_source()->set_voltage(voltage.evaluate());
}
void VoltageSource::toProto(proto::Edge* proto,
                            const double* parameters) const {
  Branch::toProto(proto, parameters);
  proto->mutable_voltage_source()->set_voltage(voltage.evaluate(parameters));
}
auto ZenerDiode::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<ZenerDiode>(*this);
}
ZenerDiode::ZenerDiode(const Vertex& from, const Vertex& to,
                       const Expression& izt, const Expression& rzt,
                       const Expression& vzt)
    : Branch(from, to), izt(izt), rzt(rzt), vzt(vzt) {}

auto ZenerDiode::getCurrent() const -> Expression {
  return (from.getVoltage() - to.getVoltage() + vzt - rzt * izt) / rzt;
}

void ZenerDiode::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  auto* protoZenerDiode = proto->mutable_zener_diode();
  protoZenerDiode->set_izt(izt.evaluate());
  protoZenerDiode->set_rzt(rzt.evaluate());
  protoZenerDiode->set_vzt(vzt.evaluate());
}
void ZenerDiode::toProto(proto::Edge* proto, const double* parameters) const {
  Branch::toProto(proto, parameters);
  auto* protoZenerDiode = proto->mutable_zener_diode();
  protoZenerDiode->set_izt(izt.evaluate(parameters));
  protoZenerDiode->set_rzt(rzt.evaluate(parameters));
  protoZenerDiode->set_vzt(vzt.evaluate(parameters));
}
