#include "branch.h"
#include "circuitGraph.h"
#include "graph.h"
#include "math/expression.h"
#include "realDiode.h"
#include "resistor.h"
#include "voltageSource.h"
#include <iostream>
#include <stdexcept>
bool testEquals(double expected, double actual) {
  double rtol = 1e-4;
  if (fabs(expected - actual) / fabs(expected) < rtol) {
    return true;
  } else {
    cout << "Test failed. Expected " << expected << ", but got " << actual
         << endl;
    return false;
  }
}

bool testBasicCircuit() {
  cout << "Testing basic circuit" << endl;
  Graph<Expression, Branch*>* graph = new Graph<Expression, Branch*>();
  Expression ref(0.0);
  Expression v1;
  Expression v2;
  Expression voltage(5.0);
  VoltageSource vs(ref, v1, voltage);
  Expression res1(2.0);
  Expression res2(3.0);
  Resistor r1(v1, v2, res1);
  Resistor r2(v2, ref, res2);
  graph->addVertex(ref);
  graph->addVertex(v1);
  graph->addVertex(v2);
  graph->addEdge(&vs);
  graph->addEdge(&r1);
  graph->addEdge(&r2);
  CircuitGraph cg(*graph);
  cg.solveCircuit();
  bool err = false;
  err |= !testEquals(5.0, v1.getValue());
  err |= !testEquals(3.0, v2.getValue());
  err |= !testEquals(1.0, vs.current.getValue());
  if (!err)
    cout << "Test Passed!" << endl;
  else
    cout << "Test Failed!" << endl;
  return err;
}

bool testRealDiodes() {
  cout << "Testing real diode circuit" << endl;
  Graph<Expression, Branch*>* graph = new Graph<Expression, Branch*>();
  Expression ref(0.0);
  Expression v;
  Expression n(2.0);
  Expression vt(0.026);
  Expression i0;
  RealDiode d(ref, v, i0, vt, n);
  Expression res1(1000);
  Expression res2(2000);
  Resistor r1(ref, v, res1);
  Resistor r2(ref, v, res2);
  graph->addVertex(ref);
  graph->addVertex(v);
  graph->addEdge(&d);
  graph->addEdge(&r1);
  graph->addEdge(&r2);
  CircuitGraph cg(*graph);
  cg.solveCircuit();
  bool err = false;
  // TODO: calculate the values manually
  if (!err)
    cout << "Test Passed!" << endl;
  return err;
}
bool testIdealDiodes() { return false; }
bool testZenerDiodes() { return false; }

int main(int argc, char* argv[]) {
  bool err = false;
  err |= testBasicCircuit();
  err |= testRealDiodes();
  err |= testIdealDiodes();
  err |= testZenerDiodes();
  if (!err)
    cout << "All tests passed!" << endl;
  else
    cout << "Tests failed. See above for details" << endl;
}
