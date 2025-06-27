#include "branch.h"
#include "math/expression.h"

class RealDiode : public Branch {
public:
  RealDiode(Expression v1, Expression v2) : Branch(v1, v2), i0(), vt(), n() {}
  RealDiode(Expression v1, Expression v2, Expression i0, Expression vt,
            Expression n)
      : Branch(v1, v2), i0(i0), vt(vt), n(n) {}
  Expression i0;
  Expression vt;
  Expression n;
  Expression getCurrent() { return i0 * Expression::exp((v1 - v2) / (n * vt)); }
};
