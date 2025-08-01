#ifndef IDEALDIODE_H
#define IDEALDIODE_H

#include "../math/expression.h"
#include "edge.h"
#include "vertex.h"

class IdealDiode : public Edge {
public:
  IdealDiode(int id, const Vertex& v1, const Vertex& v2,
             const Expression& voltage, const Expression& current)
      : Edge(id, v1, v2), voltage(voltage), current(current) {}

  Expression getCurrent() {
    return Expression::makeConditional((v1.getVoltage() - v2.getVoltage()) <
                                           Expression(0.0),
                                       Expression(0.0), current);
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
#endif // !IDEALDIODE_H
