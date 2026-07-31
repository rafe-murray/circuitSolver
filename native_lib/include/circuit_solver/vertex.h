#ifndef VERTEX_H
#define VERTEX_H

#include <uuid.h>

#include <memory>
#include <optional>

#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"

// TODO: add a cpp file
class Vertex {
 public:
  Vertex(uuids::uuid id, double voltage) : id(id), voltage(voltage) {}
  explicit Vertex(uuids::uuid id) : id(id) {}
  // For maps
  Vertex() = default;
  auto operator==(const Vertex& rhs) const -> bool { return id == rhs.id; }
  auto getVoltage() const -> Expression { return voltage; };
  auto getId() const -> uuids::uuid { return id; };
  void toProto(proto::Vertex* proto) {
    std::string idString = uuids::to_string(id);
    proto->set_id(idString);
    proto->set_voltage(voltage.evaluate());
  }
  void toProto(proto::Vertex* proto, std::span<const double> parameters) {
    std::string idString = uuids::to_string(id);
    proto->set_id(idString);
    proto->set_voltage(voltage.evaluate(parameters));
  }
  static auto fromProto(const proto::Vertex& proto) -> std::optional<Vertex> {
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
    }
    return Vertex(id);
  }

 private:
  uuids::uuid id;
  Expression voltage;
};
using VertexMap = std::unordered_map<uuids::uuid, std::unique_ptr<Vertex>>;

#endif
