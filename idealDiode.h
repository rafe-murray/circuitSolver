#include "branch.h"
#include "math/expression.h"

class IdealDiode : public Branch {
public:
  IdealDiode(const Expression& v1, const Expression& v2,
             const Expression& voltage, const Expression& current)
      : Branch(v1, v2), voltage(voltage), current(current) {}

  Expression getCurrent() {
    return Expression::makeConditional((v1 - v2) < Expression(0.0),
                                       Expression(0.0), current);
  }
  Expression constraint() {
    return Expression::makeConditional(current > Expression(0.0), v1 - v2,
                                       v1 - v2 + voltage);
  }

private:
  Expression voltage;
  Expression current;
};
