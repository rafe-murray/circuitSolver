#include "expression.h"

Expression::Expression(set<Variable *> vars, expressionFunction fn)
    : vars(vars), fn(fn) {}

Expression::Expression()
    : Expression(set<Variable *>(),
                 [](vector<double>, expressionMap) { return 0.0; }) {}

Expression Expression::operator+(const Expression &other) {
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

Expression Expression::operator-(const Expression &other) {
  set<Variable *> newVars = vars;
  newVars.insert(other.vars.begin(), other.vars.end());

  expressionFunction newFn = [&](vector<double> args, expressionMap) {
    expressionMap varMapping;
    unsigned i = 0;
    for (auto var : newVars) {
      varMapping[var] = i;
      i++;
    }
    return fn(args, varMapping) - other.fn(args, varMapping);
  };

  return Expression(newVars, newFn);
}

Expression Expression::square() {
  expressionFunction newFn = [&](vector<double> args, expressionMap map) {
    return fn(args, map) * fn(args, map);
  };
  return Expression(vars, newFn);
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
