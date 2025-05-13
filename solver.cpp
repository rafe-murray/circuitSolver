#include "solver.h"
void Solver::solveCircuit(CircuitGraph graph) {
  Expression error = graph.getErrorExpression();
  set<const Variable *> unknowns = error.getUnknowns();
  nlopt::opt opt(nlopt::LD_MMA, unknowns.size());
  opt.set_min_objective(error.toFunction(), error.getFunctionData());
  double resultVal;
  vector<double> solution(unknowns.size());
  nlopt::result result = opt.optimize(solution, resultVal);
}
