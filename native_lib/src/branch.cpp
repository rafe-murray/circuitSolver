#include "circuit_solver/branch.h"

#include <uuid.h>

#include <utility>

#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

using circuitsolver::expression::exp;

Branch::Branch(BranchConnections connections)
    : connections(std::move(connections)) {}
auto Branch::getFrom() const -> Vertex { return connections.from; }
auto Branch::getTo() const -> Vertex { return connections.to; }
auto Branch::getConstraint() const -> Expression { return 0; }

void Branch::toProto(proto::Edge* proto) const {
  std::string fromId = uuids::to_string(connections.from.getId());
  std::string toId = uuids::to_string(connections.from.getId());
  proto->set_from_id(fromId);
  proto->set_to_id(toId);
  proto->set_current(this->getCurrent().evaluate());
}
void Branch::toProto(proto::Edge* proto,
                     std::span<const double> arguments) const {
  std::string fromId = uuids::to_string(connections.from.getId());
  std::string toId = uuids::to_string(connections.to.getId());
  proto->set_from_id(fromId);
  proto->set_to_id(toId);
  proto->set_current(this->getCurrent().evaluate(arguments));
}

auto CurrentSource::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<CurrentSource>(*this);
}
CurrentSource::CurrentSource(const BranchConnections& connections,
                             Expression current)
    : Branch(connections), current(std::move(current)) {}
auto CurrentSource::getCurrent() const -> Expression { return current; };
auto CurrentSource::getConstraint() const -> Expression {
  return getFrom().getVoltage() + voltage - getTo().getVoltage();
}
void CurrentSource::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_current_source()->set_voltage(voltage.evaluate());
}
void CurrentSource::toProto(proto::Edge* proto,
                            std::span<const double> arguments) const {
  Branch::toProto(proto, arguments);
  proto->mutable_current_source()->set_voltage(voltage.evaluate(arguments));
}

auto IdealDiode::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<IdealDiode>(*this);
}

IdealDiode::IdealDiode(const BranchConnections& connections,
                       IdealDiodeParameters parameters)
    : Branch(connections),
      parameters(std::move(parameters)),
      constraint(Expression::makeConditional(
          this->parameters.current > Expression(0.0),
          getFrom().getVoltage() - getTo().getVoltage(),
          getFrom().getVoltage() - getTo().getVoltage() +
              this->parameters.voltage)),
      conditionalCurrent(Expression::makeConditional(
          (getFrom().getVoltage() - getTo().getVoltage()) < Expression(0.0),
          Expression(0.0), this->parameters.current)) {}

auto IdealDiode::getCurrent() const -> Expression { return conditionalCurrent; }

auto IdealDiode::getConstraint() const -> Expression { return constraint; }

void IdealDiode::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_ideal_diode()->set_voltage(parameters.voltage.evaluate());
}

void IdealDiode::toProto(proto::Edge* proto,
                         std::span<const double> arguments) const {
  Branch::toProto(proto, arguments);
  proto->mutable_ideal_diode()->set_voltage(
      parameters.voltage.evaluate(arguments));
}

// TODO: change

auto RealDiode::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<RealDiode>(*this);
}

RealDiode::RealDiode(const BranchConnections& connections,
                     RealDiodeParameters parameters)
    : Branch(connections), parameters(std::move(parameters)) {}

auto RealDiode::getCurrent() const -> Expression {
  return parameters.i0 * exp((getFrom().getVoltage() - getTo().getVoltage()) /
                             (parameters.n * parameters.vt));
}

void RealDiode::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  auto* protoRealDiode = proto->mutable_real_diode();
  protoRealDiode->set_i0(parameters.i0.evaluate());
  protoRealDiode->set_vt(parameters.vt.evaluate());
  protoRealDiode->set_n(parameters.n.evaluate());
}

void RealDiode::toProto(proto::Edge* proto,
                        std::span<const double> arguments) const {
  Branch::toProto(proto, arguments);
  auto* protoRealDiode = proto->mutable_real_diode();
  protoRealDiode->set_i0(parameters.i0.evaluate(arguments));
  protoRealDiode->set_vt(parameters.vt.evaluate(arguments));
  protoRealDiode->set_n(parameters.n.evaluate(arguments));
}

auto Resistor::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<Resistor>(*this);
}

Resistor::Resistor(const BranchConnections& connections, Expression resistance)
    : Branch(connections), resistance(std::move(resistance)) {}

// The resistance of the resistor in the branch, in Ohms
auto Resistor::getCurrent() const -> Expression {
  return (getFrom().getVoltage() - getTo().getVoltage()) / resistance;
}

void Resistor::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_resistor()->set_resistance(resistance.evaluate());
}

void Resistor::toProto(proto::Edge* proto,
                       std::span<const double> arguments) const {
  Branch::toProto(proto, arguments);
  proto->mutable_resistor()->set_resistance(resistance.evaluate(arguments));
}

auto VoltageSource::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<VoltageSource>(*this);
}

VoltageSource::VoltageSource(const BranchConnections& connections,
                             Expression voltage)
    : Branch(connections), voltage(std::move(voltage)) {}

// The voltage gain getFrom() the getFrom() getTo() getTo(), in Volts
auto VoltageSource::getCurrent() const -> Expression { return current; };

auto VoltageSource::getConstraint() const -> Expression {
  return getFrom().getVoltage() + voltage - getTo().getVoltage();
}

void VoltageSource::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  proto->mutable_voltage_source()->set_voltage(voltage.evaluate());
}

void VoltageSource::toProto(proto::Edge* proto,
                            std::span<const double> arguments) const {
  Branch::toProto(proto, arguments);
  proto->mutable_voltage_source()->set_voltage(voltage.evaluate(arguments));
}
auto ZenerDiode::copy() const -> std::unique_ptr<Branch> {
  return std::make_unique<ZenerDiode>(*this);
}
ZenerDiode::ZenerDiode(BranchConnections connections,
                       ZenerDiodeParameters parameters)
    : Branch(std::move(connections)), parameters(std::move(parameters)) {}

auto ZenerDiode::getCurrent() const -> Expression {
  return (getFrom().getVoltage() - getTo().getVoltage() + parameters.vzt -
          parameters.rzt * parameters.izt) /
         parameters.rzt;
}

void ZenerDiode::toProto(proto::Edge* proto) const {
  Branch::toProto(proto);
  auto* protoZenerDiode = proto->mutable_zener_diode();
  protoZenerDiode->set_izt(parameters.izt.evaluate());
  protoZenerDiode->set_rzt(parameters.rzt.evaluate());
  protoZenerDiode->set_vzt(parameters.vzt.evaluate());
}

void ZenerDiode::toProto(proto::Edge* proto,
                         std::span<const double> arguments) const {
  Branch::toProto(proto, arguments);
  auto* protoZenerDiode = proto->mutable_zener_diode();
  protoZenerDiode->set_izt(parameters.izt.evaluate(arguments));
  protoZenerDiode->set_rzt(parameters.rzt.evaluate(arguments));
  protoZenerDiode->set_vzt(parameters.vzt.evaluate(arguments));
}
