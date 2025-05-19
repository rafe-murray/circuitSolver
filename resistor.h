#ifndef RESISTOR_H
#define RESISTOR_H
#include "branch.h"
#include "math/expression.h"

class Resistor : public Branch {
public:
  Resistor(const Expression& v1, const Expression& v2,
           const Expression& resistance)
      : resistance(resistance), Branch(v1, v2) {}
  // The resistance of the resistor in the branch, in Ohms
  Expression resistance;
  Expression getCurrent() { return (v1 - v2) / resistance; }
};

#endif
