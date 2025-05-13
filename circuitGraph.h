#include "branch.h"
#include "graph.h"
#include "math/expressionNode.h"

class CircuitGraph {
public:
  CircuitGraph(Graph<Variable, Branch> graph);
  Expression getErrorExpression();
  void solveCircuit() {
    Expression error = getErrorExpression();
    set<const Variable *> unknowns = error.getUnknowns();
    nlopt::opt opt(nlopt::LD_MMA, unknowns.size());
    opt.set_min_objective(error.toFunction(), error.getFunctionData());
    double resultVal;
    vector<double> solution(unknowns.size());
    nlopt::result result = opt.optimize(solution, resultVal);
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
  Expression getNodeCurrents(Variable node);
  const Graph<Variable, Branch> graph;
};
