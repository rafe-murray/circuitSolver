#ifndef CURRENT_SOURCE_H
#define CURRENT_SOURCE_H
#include "../math/expression.h"
#include "edge.h"
#include "vertex.h"
#include <alloca.h>
#include <rapidjson/document.h>
class CurrentSource : public Edge {
public:
  ~CurrentSource() {}
  CurrentSource(int id, const Vertex& v1, const Vertex& v2,
                const Expression& current)
      : current(current), Edge(id, v1, v2) {}
  CurrentSource(int id, const Vertex& v1, const Vertex& v2)
      : CurrentSource(id, v1, v2, Expression()) {}
  // The voltage gain from the v1 to v2, in Volts
  Expression voltage;
  Expression current;
  Expression getCurrent() const override { return current; };
  Expression getConstraint() const override {
    return v1.getVoltage() + voltage - v2.getVoltage();
  }
  rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "currentSource", allocator);
    return edge;
  }
};

#endif
