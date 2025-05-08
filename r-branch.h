#include "branch.h"

class Resistor : public Branch {
public:
  // The resistance of the resistor in the branch, in Ohms
  Variable resistance;

  /*
   * See Branch,current()
   */
  Variable current();
};
