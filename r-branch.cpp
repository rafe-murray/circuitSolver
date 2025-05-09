#include "r-branch.h"
#include <unordered_map>
Expression Resistor::current() {
  set<Variable *> vars;
  vars.insert(resistance);
  vars.insert(v1);
  vars.insert(v2);
  expressionFunction fn = [&](vector<double> args, expressionMap map) {
    double voltage1 = args[map[v1]];
    double voltage2 = args[map[v2]];
    double r = args[map[resistance]];
    return (voltage1 - voltage2) / r;
  };
  return Expression(vars, fn);
}
