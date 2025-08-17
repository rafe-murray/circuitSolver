#ifndef EDGE_H
#define EDGE_H

#include <rapidjson/allocators.h>
#include <rapidjson/document.h>
#include <rapidjson/rapidjson.h>

#include "expression.h"
#include "vertex.h"

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
  virtual rapidjson::Value toJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const = 0;

 protected:
  // The voltage of one of the branch's nodes, in Volts
  Vertex v1;
  // The voltage of the other node, in Volts
  Vertex v2;

  rapidjson::Value getCommonJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const;

 private:
  // Identifier for the branch, should be unique for the graph
  int id;
};

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
  rapidjson::Value toJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "currentSource", allocator);
    return edge;
  }
};

class IdealDiode : public Edge {
 public:
  ~IdealDiode() {}
  IdealDiode(int id, const Vertex& v1, const Vertex& v2,
             const Expression& voltage, const Expression& current)
      : Edge(id, v1, v2), voltage(voltage), current(current) {}

  Expression getCurrent() {
    return Expression::makeConditional(
        (v1.getVoltage() - v2.getVoltage()) < Expression(0.0), Expression(0.0),
        current);
  }
  Expression constraint() {
    return Expression::makeConditional(
        current > Expression(0.0), v1.getVoltage() - v2.getVoltage(),
        v1.getVoltage() - v2.getVoltage() + voltage);
  }

 private:
  Expression voltage;
  Expression current;
};

class RealDiode : public Edge {
 public:
  ~RealDiode() {}
  RealDiode(int id, const Vertex& v1, const Vertex& v2)
      : Edge(id, v1, v2), i0(), vt(), n() {}
  RealDiode(int id, const Vertex& v1, const Vertex& v2, Expression i0,
            Expression vt, Expression n)
      : Edge(id, v1, v2), i0(i0), vt(vt), n(n) {}
  Expression getCurrent() {
    return i0 * std::exp((v1.getVoltage() - v2.getVoltage()) / (n * vt));
  }

  rapidjson::Value toJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "realDiode", allocator);
    edge.AddMember("i0", i0.evaluate(), allocator);
    edge.AddMember("vt", vt.evaluate(), allocator);
    edge.AddMember("n", n.evaluate(), allocator);
    return edge;
  }

 private:
  Expression i0;
  Expression vt;
  Expression n;
};

class Resistor : public Edge {
 public:
  ~Resistor() {}
  Resistor(int id, const Vertex& v1, const Vertex& v2,
           const Expression& resistance)
      : resistance(resistance), Edge(id, v1, v2) {}
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  Expression getCurrent() const override {
    return (v1.getVoltage() - v2.getVoltage()) / resistance;
  }

  rapidjson::Value toJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "resistor", allocator);
    edge.AddMember("resistance", resistance.evaluate(), allocator);
    return edge;
  }
};

class VoltageSource : public Edge {
 public:
  ~VoltageSource() {}
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
  rapidjson::Value toJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "voltageSource", allocator);
    edge.AddMember("voltage", voltage.evaluate(), allocator);
    return edge;
  }
};

// TODO: keep the information from constructor args
class ZenerDiode : public Edge {
 public:
  ~ZenerDiode() {}
  ZenerDiode(int id, const Vertex& v1, const Vertex& v2, const Expression& vzt,
             const Expression& rzt, const Expression& izt)
      : resistance(rzt), voltage(vzt - rzt * izt), Edge(id, v1, v2) {}

  Expression getCurrent() {
    return (v1.getVoltage() - v2.getVoltage() + voltage) / resistance;
  }

  rapidjson::Value toJson(
      rapidjson::MemoryPoolAllocator<>& allocator) const override {
    rapidjson::Value edge = getCommonJson(allocator);
    edge.AddMember("type", "zenerDiode", allocator);
    edge.AddMember("voltage", voltage.evaluate(), allocator);
    edge.AddMember("resistance", resistance.evaluate(), allocator);
    return edge;
  }

 private:
  Expression voltage;
  Expression resistance;
};
#endif
