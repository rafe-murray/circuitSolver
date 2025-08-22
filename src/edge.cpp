#include "edge.h"

#include <memory>

#include "circuitGraphMessage.pb.h"
#include "vertex.h"

Edge::Edge(int id, std::unique_ptr<Branch> branch)
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

unsigned Edge::getId() const { return id; };
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

void Edge::toProto(circuitsolver::CircuitGraphMessage::Edge* proto) {
  return branch->toProto(proto);
}
std::optional<Edge> Edge::fromProto(
    circuitsolver::CircuitGraphMessage::Edge proto,
    const std::vector<std::unique_ptr<Vertex>>& vertices) {
  if (!proto.has_fromid() || !proto.has_toid() || !proto.has_id()) {
    return std::nullopt;
  }
  std::unique_ptr<Branch> newBranch;
  const Vertex& from = *vertices[proto.fromid()];
  const Vertex& to = *vertices[proto.toid()];
  switch (proto.specificBranch_case()) {
    case circuitsolver::CircuitGraphMessage::Edge::kCurrentSource: {
      Expression current;
      if (proto.has_current()) {
        current = proto.current();
      }
      newBranch = std::make_unique<CurrentSource>(from, to, current);
      break;
    }
    case circuitsolver::CircuitGraphMessage::Edge::kIdealDiode: {
      Expression current, voltage;
      if (proto.has_current()) {
        current = proto.current();
      }
      if (proto.idealdiode().has_voltage()) {
        voltage = proto.idealdiode().voltage();
      }
      newBranch = std::make_unique<IdealDiode>(from, to, voltage, current);
      break;
    }
    case circuitsolver::CircuitGraphMessage::Edge::kRealDiode: {
      Expression i0, n, vt;
      if (proto.realdiode().has_i0()) {
        i0 = proto.realdiode().i0();
      }
      if (proto.realdiode().has_n()) {
        n = proto.realdiode().n();
      }
      if (proto.realdiode().has_vt()) {
        vt = proto.realdiode().vt();
      }
      newBranch = std::make_unique<RealDiode>(from, to, i0, n, vt);
    }
    case circuitsolver::CircuitGraphMessage::Edge::kResistor: {
      Expression resistance;
      if (proto.resistor().has_resistance()) {
        resistance = proto.resistor().resistance();
      }
      newBranch = std::make_unique<Resistor>(from, to, resistance);
    }
    case circuitsolver::CircuitGraphMessage::Edge::kVoltageSource: {
      Expression voltage;
      if (proto.voltagesource().has_voltage()) {
        voltage = proto.voltagesource().voltage();
      }
      newBranch = std::make_unique<VoltageSource>(from, to, voltage);
    }
    case circuitsolver::CircuitGraphMessage::Edge::kZenerDiode: {
      Expression izt, rzt, vzt;
      if (proto.zenerdiode().has_izt()) {
        izt = proto.zenerdiode().izt();
      }
      if (proto.zenerdiode().has_rzt()) {
        rzt = proto.zenerdiode().rzt();
      }
      if (proto.zenerdiode().has_vzt()) {
        vzt = proto.zenerdiode().vzt();
      }
      newBranch = std::make_unique<ZenerDiode>(from, to, izt, rzt, vzt);
    }
    case circuitsolver::CircuitGraphMessage::Edge::SPECIFICBRANCH_NOT_SET:
      return std::nullopt;
  }
  return Edge(proto.id(), std::move(newBranch));
}

namespace std {
template <>
struct hash<Edge> {
  size_t operator()(const Edge& e) const { return hash<int>()(e.getId()); }
};
}  // namespace std
