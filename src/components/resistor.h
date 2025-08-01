#ifndef RESISTOR_H
#define RESISTOR_H
#include "../math/expression.h"
#include "edge.h"
#include "vertex.h"
#include <alloca.h>
#include <rapidjson/document.h>

class Resistor : public Edge {
public:
  Resistor(int id, const Vertex& v1, const Vertex& v2,
           const Expression& resistance)
      : resistance(resistance), Edge(id, v1, v2) {}
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  Expression getCurrent() const override {
    return (v1.getVoltage() - v2.getVoltage()) / resistance;
  }

  rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "resistor", allocator);
    edge.AddMember("resistance", resistance.getValue(), allocator);
    return edge;
  }
};

#endif
