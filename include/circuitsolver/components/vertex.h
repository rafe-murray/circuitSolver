#ifndef VERTEX_H
#define VERTEX_H
#include "../expression.h"
#include <rapidjson/allocators.h>
#include <rapidjson/document.h>
#include <rapidjson/rapidjson.h>

class Vertex {
public:
  Vertex(int id, double voltage) : id(id), voltage(voltage) {}
  Vertex(int id) : id(id) {}
  // For maps
  Vertex() {}
  bool operator==(const Vertex& rhs) const { return id == rhs.id; }
  Expression getVoltage() const { return voltage; };
  int getId() const { return id; };
  rapidjson::Value toJson(rapidjson::MemoryPoolAllocator<>& allocator) const {
    rapidjson::Value vertex(rapidjson::kObjectType);
    vertex.AddMember("id", id, allocator);
    vertex.AddMember("voltage", voltage.evaluate(), allocator);
    return vertex;
  }

private:
  int id;
  Expression voltage;
  friend class Edge;
};

namespace std {
template <> struct hash<Vertex> {
  size_t operator()(const Vertex& b) const {
    hash<int> intHash;
    return intHash(b.getId());
  }
};
} // namespace std
#endif
