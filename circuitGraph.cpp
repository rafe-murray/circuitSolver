#include "circuitGraph.h"
#include "math/expression.h"
#include "math/variable.h"

CircuitGraph::CircuitGraph(Graph<Variable, Branch> graph) : graph(graph) {}
Expression CircuitGraph::getErrorExpression() {
  Expression error;
  for (Variable node : graph.getVertices()) {
    Expression netCurrent = getNodeCurrents(node);
    error = error + netCurrent * netCurrent;
  }
  for (Branch branch : graph.getEdges()) {
    Expression constraint = branch.constraint();
    error = error + constraint * constraint;
  }
  return error;
}

Expression CircuitGraph::getNodeCurrents(Variable node) {
  Expression nodeCurrents;
  for (Branch branch : graph.getIncident(node)) {
    Expression current = branch.current();
    nodeCurrents = nodeCurrents + current * current;
  }
  return nodeCurrents;
}
