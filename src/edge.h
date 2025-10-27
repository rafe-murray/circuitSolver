#ifndef EDGE_H
#define EDGE_H

#include <rapidjson/allocators.h>
#include <rapidjson/document.h>
#include <rapidjson/rapidjson.h>

#include "circuitGraphMessage.pb.h"
#include "expression.h"
#include "src/branch.h"
#include "vertex.h"

class Edge {
 public:
  Edge(int id, std::unique_ptr<Branch> branch);
  template <typename T>
  Edge(int id, const T& branch) : id(id), branch(std::make_unique<T>(branch)){};
  // For hash map; do not use
  Edge();
  Edge(const Edge& other);
  Edge& operator=(const Edge& other);
  // Move constructor
  Edge(Edge&& rhs) noexcept;

  unsigned getId() const;
  Vertex getFrom() const;
  Vertex getTo() const;
  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  Expression getCurrent() const;

  Expression getConstraint() const;
  bool operator==(const Edge& rhs) const;
  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto);
  void toProto(circuitsolver::CircuitGraphMessage::Edge* proto,
               const double* parameters);
  static std::optional<Edge> fromProto(
      circuitsolver::CircuitGraphMessage::Edge proto,
      const std::vector<std::unique_ptr<Vertex>>& vertices);

 private:
  // Identifier for the branch, should be unique to a graph
  unsigned id;
  std::unique_ptr<Branch> branch;
};

#endif
