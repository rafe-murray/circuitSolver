#include "circuitGraph.h"
#include "math/expression.h"

CircuitGraph::CircuitGraph(Graph<Expression, Branch*>& graph) : graph(graph) {}
Expression CircuitGraph::getErrorExpression() {
  Expression error(0.0);
  for (Expression node : graph.getVertices()) {
    Expression netCurrent = getNodeCurrents(node);
    error = error + netCurrent * netCurrent;
  }
  for (const Branch* const branch : graph.getEdges()) {
    Expression constraint = branch->constraint();
    error = error + constraint * constraint;
  }
  return error;
}

Expression CircuitGraph::getNodeCurrents(Expression node) {
  Expression nodeCurrents(0.0);
  for (Branch* branch : graph.getIncident(node)) {
    Expression current = branch->getCurrent();
    if (branch->v1 == node) {
      nodeCurrents = nodeCurrents - current;
    } else {
      nodeCurrents = nodeCurrents + current;
    }
  }
  return nodeCurrents;
}
