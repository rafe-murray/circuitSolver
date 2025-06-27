#ifndef CURRENT_SOURCE_H
#define CURRENT_SOURCE_H
#include "branch.h"
#include "math/expression.h"
class CurrentSource : public Branch {
public:
  CurrentSource(const Expression& v1, const Expression& v2,
                const Expression& current)
      : current(voltage), Branch(v1, v2) {}
  // The voltage gain from the v1 to v2, in Volts
  Expression voltage;
  Expression current;
  Expression getCurrent() { return current; };
  Expression constraint() const { return v1 + voltage - v2; }
};

#endif
