#include "edge.h"

#include <rapidjson/allocators.h>
#include <rapidjson/document.h>
#include <rapidjson/rapidjson.h>

#include "vertex.h"

Edge::~Edge() {}
// TODO: fix passing by reference; want v1 and v2 to point to the original
// locations in memory!
Edge::Edge(int id, const Vertex& v1, const Vertex& v2)
    : id(id), v1(v1), v2(v2) {}
// For hash map; do not use
Edge::Edge() {}

int Edge::getId() const { return id; };
Vertex Edge::getV1() const { return v1; };
Vertex Edge::getV2() const { return v2; };
/**
 * Returns an expression that represents the current through this branch, in
 * Amps
 */
Expression Edge::getCurrent() const { return Expression(); }

Expression Edge::getConstraint() const { return Expression(0.0); }
bool Edge::operator==(const Edge& rhs) const { return id == rhs.id; }
// Edge& operator=(const Edge& other);

rapidjson::Value Edge::getCommonJson(
    rapidjson::MemoryPoolAllocator<>& allocator) const {
  rapidjson::Value edge(rapidjson::kObjectType);
  edge.AddMember("id", id, allocator);
  edge.AddMember("from", v1.getId(), allocator);
  edge.AddMember("to", v2.getId(), allocator);
  edge.AddMember("current", getCurrent().evaluate(), allocator);
  return edge;
}

namespace std {
template <>
struct hash<Edge> {
  size_t operator()(const Edge& b) const {
    hash<int> intHash;
    return intHash(b.getId());
  }
};
}  // namespace std
