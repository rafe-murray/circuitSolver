#ifndef EDGE_H
#define EDGE_H

#include <uuid.h>

#include <memory>

#include "branch.h"
#include "expression.h"
#include "proto.h"
#include "vertex.h"

class Edge {
 public:
  Edge(uuids::uuid id, std::unique_ptr<Branch> branch);
  template <typename T>
  Edge(uuids::uuid id, const T& branch)
      : id(id), branch(std::make_unique<T>(branch)){};
  // For hash map; do not use
  Edge();
  Edge(const Edge& other);
  Edge& operator=(const Edge& other);
  // Move constructor
  Edge(Edge&& rhs) noexcept;

  uuids::uuid getId() const;
  Vertex getFrom() const;
  Vertex getTo() const;
  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  Expression getCurrent() const;

  Expression getConstraint() const;
  bool operator==(const Edge& rhs) const;
  void toProto(proto::Edge* proto);
  void toProto(proto::Edge* proto, const double* parameters);
  static std::optional<Edge> fromProto(proto::Edge proto,
                                       const VertexMap& vertices);

 private:
  // Identifier for the branch, should be unique to a graph
  uuids::uuid id;
  std::unique_ptr<Branch> branch;
};

using EdgeMap = std::unordered_map<uuids::uuid, std::unique_ptr<Edge>>;

#endif
