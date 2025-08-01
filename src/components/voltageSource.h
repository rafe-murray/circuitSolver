#ifndef VOLTAGE_SOURCE_H
#define VOLTAGE_SOURCE_H
#include "../math/expression.h"
#include "edge.h"
#include "vertex.h"
#include <rapidjson/allocators.h>
class VoltageSource : public Edge {
public:
  VoltageSource(int id, const Vertex& v1, const Vertex& v2,
                const Expression& voltage)
      : voltage(voltage), Edge(id, v1, v2) {}
  VoltageSource(int id, const Vertex& v1, const Vertex& v2)
      : VoltageSource(id, v1, v2, Expression()) {}
  // The voltage gain from the v1 to v2, in Volts
  Expression voltage;
  Expression current;
  Expression getCurrent() { return current; };
  Expression getConstraint() const override {
    return v1.getVoltage() + voltage - v2.getVoltage();
  }
  rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "voltageSource", allocator);
    edge.AddMember("voltage", voltage.getValue(), allocator);
    return edge;
  }
};

#endif
