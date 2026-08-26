#ifndef EDGE_H
#define EDGE_H

#include <stduuid/uuid.h>

#include <memory>
#include <optional>
#include <span>
#include <unordered_map>

#include "circuit_solver/branch.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

/// Represents a circuit component
class Edge {
 public:
  /// Creates a new `Edge`
  Edge(uuids::uuid id, std::unique_ptr<Branch> branch);
  template <typename T>
  Edge(uuids::uuid id, const T& branch)
      : id(id), branch(std::make_unique<T>(branch)) {};
  // For hash map; do not use
  Edge();

  Edge(const Edge& other);
  auto operator=(const Edge& other) -> Edge&;
  Edge(Edge&& rhs) noexcept = default;
  auto operator=(Edge&& other) noexcept -> Edge& = default;
  ~Edge() = default;

  [[nodiscard]] auto getId() const -> uuids::uuid;
  [[nodiscard]] auto getFrom() const -> Vertex;
  [[nodiscard]] auto getTo() const -> Vertex;
  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  [[nodiscard]] auto getCurrent() const -> Expression;

  [[nodiscard]] auto getConstraint() const -> Expression;
  auto operator==(const Edge& rhs) const -> bool;
  void toProto(proto::Edge* proto);
  void toProto(proto::Edge* proto, std::span<const double> parameters);
  static auto fromProto(const proto::Edge& proto, const VertexMap& vertices)
      -> std::optional<Edge>;

 private:
  // Identifier for the branch, should be unique to a graph
  uuids::uuid id;
  std::unique_ptr<Branch> branch;
};

using EdgeMap = std::unordered_map<uuids::uuid, std::unique_ptr<Edge>>;

#endif
