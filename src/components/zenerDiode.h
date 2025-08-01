#ifndef ZENER_DIODE_H
#define ZENER_DIODE_H

#include "../math/expression.h"
#include "edge.h"
#include "vertex.h"
#include <rapidjson/document.h>

class ZenerDiode : public Edge {
public:
  ZenerDiode(int id, const Vertex& v1, const Vertex& v2, const Expression& vzt,
             const Expression& rzt, const Expression& izt)
      : resistance(rzt), voltage(vzt - rzt * izt), Edge(id, v1, v2) {}

  Expression getCurrent() {
    return (v1.getVoltage() - v2.getVoltage() + voltage) / resistance;
  }

  rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "zenerDiode", allocator);
    edge.AddMember("voltage", voltage.getValue(), allocator);
    edge.AddMember("resistance", resistance.getValue(), allocator);
    return edge;
  }

private:
  Expression voltage;
  Expression resistance;
};
#endif // !ZENER_DIODE_H
