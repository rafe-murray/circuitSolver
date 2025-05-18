#include "branch.h"
#include "circuitGraph.h"
#include "math/expression.h"
#include "resistor.h"
#include "voltageSource.h"
#include <iostream>
#include <stdexcept>

int main(int argc, char *argv[]) {
  // Simple test circuit
  Graph<Expression, Branch> graph;
  Expression ref(0.0);
  Expression v1;
  Expression v2;
  Expression voltage(5.0);
  VoltageSource vs(ref, v1, voltage);
  Expression res1(2.0);
  Expression res2(3.0);
  Resistor r1(v1, v2, res1);
  Resistor r2(v2, ref, res2);
  graph.addVertex(ref);
  graph.addVertex(v1);
  graph.addVertex(v2);
  graph.addEdge(vs);
  graph.addEdge(r1);
  graph.addEdge(r2);
  CircuitGraph cg(graph);
  try {
    cg.solveCircuit();
  } catch (runtime_error &e) {
    cerr << e.what() << endl;
  }
  cout << "Expected: 5.0, actual: " << v1.getValue() << endl;
  cout << "Expected: 3.0, actual: " << v2.getValue() << endl;
  cout << "Expected: 1.0, actual: " << vs.current.getValue() << endl;
}
