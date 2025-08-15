#ifndef EDGE_H
#define EDGE_H
#include "../expression.h"
#include "vertex.h"
#include <rapidjson/allocators.h>
#include <rapidjson/document.h>
#include <rapidjson/rapidjson.h>

class Edge {
public:
  virtual ~Edge();
  // TODO: fix passing by reference; want v1 and v2 to point to the original
  // locations in memory!
  Edge(int id, const Vertex& v1, const Vertex& v2);
  // For hash map; do not use
  Edge();

  int getId() const;
  Vertex getV1() const;
  Vertex getV2() const;
  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  virtual Expression getCurrent() const;

  virtual Expression getConstraint() const;
  bool operator==(const Edge& rhs) const;
  // Edge& operator=(const Edge& other);
  virtual rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const = 0;

protected:
  // The voltage of one of the branch's nodes, in Volts
  Vertex v1;
  // The voltage of the other node, in Volts
  Vertex v2;

  rapidjson::Value
  getCommonJson(rapidjson::MemoryPoolAllocator<>& allocator) const;

private:
  // Identifier for the branch, should be unique for the graph
  int id;
};
#endif
