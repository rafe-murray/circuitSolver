#include "branch.h"
class VoltageSource : public Branch {
public:
  // The voltage gain from the source/battery, in Volts
  Variable *voltage;
  Variable *_current;
  Expression current();
};
