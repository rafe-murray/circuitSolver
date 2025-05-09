#include "expression.h"
#include <unordered_map>
#include <vector>

Expression::Expression(set<Variable *> vars, expressionFunction fn)
    : vars(vars), fn(fn) {}

Expression Expression::operator+(Expression other) {
  set<Variable *> newVars = vars;
  newVars.insert(other.vars.begin(), other.vars.end());

  expressionFunction newFn = [&](vector<double> args, expressionMap) {
    expressionMap varMapping;
    unsigned i = 0;
    for (auto var : newVars) {
      varMapping[var] = i;
      i++;
    }
    return fn(args, varMapping) + other.fn(args, varMapping);
  };

  return Expression(newVars, newFn);
}

function<double(vector<double>)> Expression::toFunction() {
  expressionMap varMapping;
  unsigned i = 0;
  for (auto var : vars) {
    varMapping[var] = i;
    i++;
  }

  function<double(vector<double>)> newFn = [&](vector<double> args) {
    vector<double> localArgs(vars.size());
    auto argsIter = args.begin();
    auto localArgsIt = localArgs.begin();
    for (auto var : vars) {
      if (var->known) {
        *localArgsIt = var->value;
      } else {
        *localArgsIt = *argsIter;
        argsIter++;
      }
      localArgsIt++;
    }
    return fn(localArgs, varMapping);
  };
  return newFn;
}

vector<Variable *> Expression::getUnknowns() {
  vector<Variable *> unknowns;
  for (Variable *var : vars) {
    if (!var->known) {
      unknowns.push_back(var);
    }
  }
  return unknowns;
}
