#ifndef REALDIODE_H
#define REALDIODE_H

#include "../math/expression.h"
#include "edge.h"
#include "vertex.h"

class RealDiode : public Edge {
public:
  RealDiode(int id, const Vertex& v1, const Vertex& v2)
      : Edge(id, v1, v2), i0(), vt(), n() {}
  RealDiode(int id, const Vertex& v1, const Vertex& v2, Expression i0,
            Expression vt, Expression n)
      : Edge(id, v1, v2), i0(i0), vt(vt), n(n) {}
  Expression getCurrent() {
    return i0 * Expression::exp((v1.getVoltage() - v2.getVoltage()) / (n * vt));
  }

  rapidjson::Value
  toJson(rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "realDiode", allocator);
    edge.AddMember("i0", i0, allocator);
    edge.AddMember("vt", vt, allocator);
    edge.AddMember("n", n, allocator);
    return edge;
  }

private:
  Expression i0;
  Expression vt;
  Expression n;
};
#endif // !REALDIODE_H
