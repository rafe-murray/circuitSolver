#include "branch.h"

class Resistor : public Branch {
public:
  // The resistance of the resistor in the branch, in Ohms
  Variable resistance;
  Expression current() { return (Expression(v1) + v2) / resistance; }
};
