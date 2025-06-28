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
  CircuitGraph* graph = new CircuitGraph();
  Expression ref(0.0);
  Expression v1;
  Expression v2;
  Expression voltage(5.0);
  VoltageSource vs(ref, v1, voltage);
  Expression res1(2.0);
  Expression res2(3.0);
  Resistor r1(v1, v2, res1);
  Resistor r2(v2, ref, res2);
  assert(graph->addVertex(ref));
  assert(graph->addVertex(v1));
  assert(graph->addVertex(v2));
  assert(graph->addEdge(&vs));
  assert(graph->addEdge(&r1));
  assert(graph->addEdge(&r2));
  graph->solveCircuit();
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
  CircuitGraph* graph = new CircuitGraph();
  Expression ref = 0;
  Expression vcc = 15;
  Expression v1;
  Expression v2;
  Expression n = 1.5;
  Expression vt = 25e-3;
  Expression i0 = 50e-12;
  RealDiode d(v1, v2, i0, vt, n);
  Expression res1(2000);
  Expression res2(3000);
  Expression res3(3000);
  Expression res4(3000);
  Resistor r1(vcc, v1, res1);
  Resistor r2(vcc, v2, res2);
  Resistor r3(v1, ref, res3);
  Resistor r4(v2, ref, res4);
  graph->addVertex(ref);
  graph->addVertex(vcc);
  graph->addVertex(v1);
  graph->addVertex(v2);
  graph->addEdge(&r1);
  graph->addEdge(&r2);
  graph->addEdge(&r3);
  graph->addEdge(&r4);
  graph->addEdge(&d);
  graph->solveCircuit();
  bool err = false;
  err |= !testEquals(8.595, v1.getValue());
  err |= !testEquals(8.006, v2.getValue());
  err |= !testEquals(337.2e-6, d.getCurrent().getValue());
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
