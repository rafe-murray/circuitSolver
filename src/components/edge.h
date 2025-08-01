#ifndef EDGE_H
#define EDGE_H
#include "../math/expression.h"
#include "vertex.h"
#include <rapidjson/allocators.h>
#include <rapidjson/document.h>
#include <rapidjson/rapidjson.h>

// using namespace std;

class Edge {
public:
  virtual ~Edge() {}
  // TODO: fix passing by reference; want v1 and v2 to point to the original
  // locations in memory!
  Edge(int id, const Vertex& v1, const Vertex& v2) : id(id), v1(v1), v2(v2) {}
  // For hash map; do not use
  Edge() {}

  int getId() const { return id; };
  Vertex getV1() const { return v1; };
  Vertex getV2() const { return v2; };
  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  virtual Expression getCurrent() const { return Expression(); }

  virtual Expression getConstraint() const { return Expression(0.0); }
  bool operator==(const Edge& rhs) const { return id == rhs.id; }
  // Edge& operator=(const Edge& other);
  virtual rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const;

protected:
  // The voltage of one of the branch's nodes, in Volts
  Vertex v1;
  // The voltage of the other node, in Volts
  Vertex v2;

  rapidjson::Value
  getCommonJson(rapidjson::MemoryPoolAllocator<>& allocator) const {
    rapidjson::Value edge(rapidjson::kObjectType);
    edge.AddMember("id", id, allocator);
    edge.AddMember("from", v1.getId(), allocator);
    edge.AddMember("to", v2.getId(), allocator);
    edge.AddMember("current", getCurrent().getValue(), allocator);
    return edge;
  }

private:
  // Identifier for the branch, should be unique for the graph
  int id;
};

namespace std {
template <> struct hash<Edge> {
  size_t operator()(const Edge& b) const {
    hash<int> intHash;
    return intHash(b.getId());
  }
};
} // namespace std
// namespace std
#endif
