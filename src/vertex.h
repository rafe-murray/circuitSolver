#ifndef VERTEX_H
#define VERTEX_H

#include "circuitGraphMessage.pb.h"
#include "expression.h"

class Vertex {
 public:
  Vertex(int id, double voltage) : id(id), voltage(voltage) {}
  Vertex(int id) : id(id) {}
  // For maps
  Vertex() {}
  bool operator==(const Vertex& rhs) const { return id == rhs.id; }
  Expression getVoltage() const { return voltage; };
  unsigned getId() const { return id; };
  void toProto(circuitsolver::CircuitGraphMessage::Vertex* proto) {
    proto->set_id(id);
    proto->set_voltage(voltage.evaluate());
  }
  static std::optional<Vertex> fromProto(
      circuitsolver::CircuitGraphMessage::Vertex proto) {
    if (!proto.has_id()) {
      return std::nullopt;
    }
    if (proto.has_voltage()) {
      return Vertex(proto.id(), proto.voltage());
    } else {
      return Vertex(proto.id());
    }
  }

 private:
  unsigned id;
  Expression voltage;
};

namespace std {
template <>
struct hash<Vertex> {
  size_t operator()(const Vertex& b) const { return hash<int>()(b.getId()); }
};
}  // namespace std
#endif
