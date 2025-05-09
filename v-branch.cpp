#include "v-branch.h"
Expression VoltageSource::current() {
  set<Variable *> vars;
  vars.insert(_current);
  expressionFunction fn = [&](vector<double> args, expressionMap map) {
    return args[map[_current]];
  };
  return Expression(vars, fn);
}
