#include "branch.h"
#include "math/expression.h"
class VoltageSource : public Branch {
public:
  VoltageSource(const Expression &v1, const Expression &v2,
                const Expression &voltage)
      : voltage(voltage), Branch(v1, v2) {}
  // The voltage gain from the v1 to v2, in Volts
  Expression voltage;
  Expression current;
  Expression getCurrent() { return current; };
  Expression constraint() { return v1 + voltage - v2; }
};
