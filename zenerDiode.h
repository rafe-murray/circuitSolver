#include "branch.h"
#include "math/expression.h"

class ZenerDiode : public Branch {
public:
  ZenerDiode(const Expression& vzt, const Expression& rzt,
             const Expression& izt)
      : resistance(rzt), voltage(vzt - rzt * izt) {}

  Expression getCurrent() { return (v1 - v2 + voltage) / resistance; }

private:
  Expression voltage;
  Expression resistance;
};
