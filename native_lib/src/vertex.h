#ifndef VERTEX_H
#define VERTEX_H

#include <memory>
#include <optional>

#include "expression.h"
#include "proto.h"
#include "uuid.h"

// TODO: add a cpp file
class Vertex {
 public:
  Vertex(uuids::uuid id, double voltage) : id(id), voltage(voltage) {}
  Vertex(uuids::uuid id) : id(id) {}
  // For maps
  Vertex() {}
  bool operator==(const Vertex& rhs) const { return id == rhs.id; }
  Expression getVoltage() const { return voltage; };
  uuids::uuid getId() const { return id; };
  void toProto(proto::Vertex* proto) {
    std::string idString = uuids::to_string(id);
    proto->set_id(idString);
    proto->set_voltage(voltage.evaluate());
  }
  void toProto(proto::Vertex* proto, const double* parameters) {
    std::string idString = uuids::to_string(id);
    proto->set_id(idString);
    proto->set_voltage(voltage.evaluate(parameters));
  }
  static std::optional<Vertex> fromProto(proto::Vertex proto) {
    if (!proto.has_id()) {
      return std::nullopt;
    }
    std::optional<uuids::uuid> optionalId =
        uuids::uuid::from_string(proto.id());
    if (!optionalId.has_value()) {
      return std::nullopt;
    }
    uuids::uuid id = optionalId.value();
    if (proto.has_voltage()) {
      return Vertex(id, proto.voltage());
    } else {
      return Vertex(id);
    }
  }

 private:
  uuids::uuid id;
  Expression voltage;
};
using VertexMap = std::unordered_map<uuids::uuid, std::unique_ptr<Vertex>>;

#endif
