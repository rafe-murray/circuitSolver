#include "branch.h"
#include "math/expression.h"
class VoltageSource : public Branch {
public:
  // The voltage gain from the v1 to v2, in Volts
  Variable voltage;
  Variable _current;
  Expression current() { return _current; };
  Expression constraint() { return Expression(v1) + voltage - v2; }
};
