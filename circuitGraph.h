#include "branch.h"
#include "graph.h"
#include "math/expression.h"
#include "math/expressionNode.h"
#include "nlopt.hpp"
#include <ostream>
#include <stdexcept>

class CircuitGraph {
public:
  CircuitGraph(Graph<Expression, Branch> graph);
  Expression getErrorExpression();
  void solveCircuit() {
    Expression error = getErrorExpression();
    error.print();
    set<const Variable *> unknowns = error.getUnknowns();
    nlopt::opt opt(nlopt::LD_MMA, unknowns.size());
    opt.set_min_objective(error.toFunction(), error.getFunctionData());
    opt.set_lower_bounds(-10);
    opt.set_upper_bounds(10);
    opt.set_xtol_rel(1e-4);
    double resultVal;
    vector<double> solution(unknowns.size());
    for (unsigned i = 0; i < solution.size(); i++) {
      solution[i] = 0.0;
    }
    try {
      nlopt::result result = opt.optimize(solution, resultVal);
    } catch (std::runtime_error &e) {
      throw e;
    }
    expressionMap map = error.getMap();
    for (auto entry : map) {
      entry.first->value = solution[entry.second];
      entry.first->known = true;
    }
  }

private:
  /**
   * Get the sum of the currents going into/out of a node
   * @param node - the node to get the currents for
   * @param unknowns - a vector containing the unknowns for the graph
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in this.graph
   */
  Expression getNodeCurrents(Expression node);
  const Graph<Expression, Branch> graph;
};
