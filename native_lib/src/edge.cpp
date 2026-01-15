#include "edge.h"

#include <memory>
#include <optional>

#include "proto.h"
#include "uuid.h"
#include "vertex.h"

Edge::Edge(uuids::uuid id, std::unique_ptr<Branch> branch)
    : id(id), branch(std::move(branch)) {}
// template<typename T>
// Edge::Edge(int id, const T& branch)
//     : id(id), branch(std::make_unique<T>(branch)) {}
// For hash map; do not use
Edge::Edge() {}

// NOTE: these might not be correct
Edge::Edge(const Edge& other) : id(other.id), branch(other.branch->copy()) {}
Edge& Edge::operator=(const Edge& other) {
  this->id = other.id;
  this->branch = other.branch->copy();
  return *this;
}
Edge::Edge(Edge&& rhs) noexcept : id(rhs.id), branch(std::move(rhs.branch)) {
  rhs.branch = nullptr;
}

uuids::uuid Edge::getId() const { return id; };
Vertex Edge::getFrom() const { return branch->getFrom(); };
Vertex Edge::getTo() const { return branch->getTo(); };
/**
 * Returns an expression that represents the current through this branch, in
 * Amps
 */
Expression Edge::getCurrent() const { return branch->getCurrent(); }

Expression Edge::getConstraint() const { return branch->getConstraint(); }
bool Edge::operator==(const Edge& rhs) const { return id == rhs.id; }
// Edge& operator=(const Edge& other);

void Edge::toProto(proto::Edge* proto) { return branch->toProto(proto); }
void Edge::toProto(proto::Edge* proto, const double* parameters) {
  return branch->toProto(proto, parameters);
}
std::optional<Edge> Edge::fromProto(proto::Edge proto,
                                    const VertexMap& vertices) {
  if (!proto.has_from_id() || !proto.has_to_id() || !proto.has_id()) {
    return std::nullopt;
  }
  std::optional<uuids::uuid> optionalFromId =
      uuids::uuid::from_string(proto.from_id());
  std::optional<uuids::uuid> optionalToId =
      uuids::uuid::from_string(proto.to_id());
  std::optional<uuids::uuid> optionalId = uuids::uuid::from_string(proto.id());
  if (!optionalId.has_value() || !optionalToId.has_value() ||
      !optionalFromId.has_value()) {
    return std::nullopt;
  }
  uuids::uuid id = optionalId.value();
  uuids::uuid fromId = optionalFromId.value();
  uuids::uuid toId = optionalToId.value();

  std::unique_ptr<Branch> newBranch;
  const Vertex& from = *vertices.at(fromId);
  const Vertex& to = *vertices.at(toId);
  switch (proto.specific_branch_case()) {
    case proto::Edge::kCurrentSource: {
      Expression current;
      if (proto.has_current()) {
        current = proto.current();
      }
      newBranch = std::make_unique<CurrentSource>(from, to, current);
      break;
    }
    case proto::Edge::kIdealDiode: {
      Expression current, voltage;
      if (proto.has_current()) {
        current = proto.current();
      }
      if (proto.ideal_diode().has_voltage()) {
        voltage = proto.ideal_diode().voltage();
      }
      newBranch = std::make_unique<IdealDiode>(from, to, voltage, current);
      break;
    }
    case proto::Edge::kRealDiode: {
      Expression i0, n, vt;
      if (proto.real_diode().has_i0()) {
        i0 = proto.real_diode().i0();
      }
      if (proto.real_diode().has_n()) {
        n = proto.real_diode().n();
      }
      if (proto.real_diode().has_vt()) {
        vt = proto.real_diode().vt();
      }
      newBranch = std::make_unique<RealDiode>(from, to, i0, n, vt);
      break;
    }
    case proto::Edge::kResistor: {
      Expression resistance;
      if (proto.resistor().has_resistance()) {
        resistance = proto.resistor().resistance();
      }
      newBranch = std::make_unique<Resistor>(from, to, resistance);
      break;
    }
    case proto::Edge::kVoltageSource: {
      Expression voltage;
      if (proto.voltage_source().has_voltage()) {
        voltage = proto.voltage_source().voltage();
      }
      newBranch = std::make_unique<VoltageSource>(from, to, voltage);
      break;
    }
    case proto::Edge::kZenerDiode: {
      Expression izt, rzt, vzt;
      if (proto.zener_diode().has_izt()) {
        izt = proto.zener_diode().izt();
      }
      if (proto.zener_diode().has_rzt()) {
        rzt = proto.zener_diode().rzt();
      }
      if (proto.zener_diode().has_vzt()) {
        vzt = proto.zener_diode().vzt();
      }
      newBranch = std::make_unique<ZenerDiode>(from, to, izt, rzt, vzt);
      break;
    }
    case proto::Edge::SPECIFIC_BRANCH_NOT_SET:
      return std::nullopt;
  }
  return Edge(id, std::move(newBranch));
}
