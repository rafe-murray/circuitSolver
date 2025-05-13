#include "math/expression.h"
#include "math/variable.h"
#include <nlopt.hpp>

using namespace std;

class Branch {
public:
  // The voltage of one of the branch's nodes, in Volts
  Variable v1;

  // The voltage of the other node, in Volts
  Variable v2;

  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  virtual Expression current();

  virtual Expression constraint() { return Expression(); }
};
