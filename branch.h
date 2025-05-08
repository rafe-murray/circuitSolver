#include "variable.h"
#include <functional>
#include <nlopt.hpp>
#include <vector>
using namespace std;
class Branch {
public:
  // The voltage of one of the branch's nodes, in Volts
  Variable v1;

  // The voltage of the other node, in Volts
  Variable v2;

  // TODO: add any other required args
  /**
   * Returns a function that calculates the current through this branch, in Amps
   */
  virtual function<double(vector<Variable>)> current();
};
