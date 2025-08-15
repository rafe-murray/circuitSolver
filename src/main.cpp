#include "circuitsolver/circuitGraph.h"
#include "circuitsolver/components/edge.h"
#include "circuitsolver/components/realDiode.h"
#include "circuitsolver/components/resistor.h"
#include "circuitsolver/components/vertex.h"
#include "circuitsolver/components/voltageSource.h"
#include "circuitsolver/expression.h"
#include <iostream>
bool testEquals(double expected, double actual) {
  double rtol = 1e-4;
  if (fabs(expected - actual) / fabs(expected) < rtol) {
    return true;
  } else {
    std::cout << "Test failed. Expected " << expected << ", but got " << actual
              << std::endl;
    return false;
  }
}

bool testBasicCircuit() {
  std::cout << "Testing basic circuit" << std::endl;
  CircuitGraph* graph = new CircuitGraph();
  Vertex ref(0, 0.0);
  Vertex v1(1);
  Vertex v2(2);
  Expression voltage(5.0);
  auto vs = std::make_shared<VoltageSource>(0, ref, v1, voltage);
  Expression res1(2.0);
  Expression res2(3.0);
  auto r1 = std::make_shared<Resistor>(1, v1, v2, res1);
  auto r2 = std::make_shared<Resistor>(2, v2, ref, res2);
  assert(graph->addVertex(ref));
  assert(graph->addVertex(v1));
  assert(graph->addVertex(v2));
  assert(graph->addEdge(vs));
  assert(graph->addEdge(r1));
  assert(graph->addEdge(r2));
  graph->solveCircuit();
  bool err = false;
  err |= !testEquals(5.0, v1.getVoltage().evaluate());
  err |= !testEquals(3.0, v2.getVoltage().evaluate());
  err |= !testEquals(1.0, vs->getCurrent().evaluate());
  if (!err)
    std::cout << "Test Passed!" << std::endl;
  else
    std::cout << "Test Failed!" << std::endl;
  return err;
}

bool testRealDiodes() {
  std::cout << "Testing real diode circuit" << std::endl;
  CircuitGraph* graph = new CircuitGraph();
  Vertex ref(0, 0.0);
  Vertex v1(1);
  Vertex v2(2);
  Vertex vcc(3, 15);
  Expression n = 1.5;
  Expression vt = 25e-3;
  Expression i0 = 50e-12;
  auto d = std::make_shared<RealDiode>(0, v1, v2, i0, vt, n);
  Expression res1(2000);
  Expression res2(3000);
  Expression res3(3000);
  Expression res4(3000);
  auto r1 = std::make_shared<Resistor>(1, vcc, v1, res1);
  auto r2 = std::make_shared<Resistor>(2, vcc, v2, res2);
  auto r3 = std::make_shared<Resistor>(3, v1, ref, res3);
  auto r4 = std::make_shared<Resistor>(4, v2, ref, res4);
  graph->addVertex(ref);
  graph->addVertex(vcc);
  graph->addVertex(v1);
  graph->addVertex(v2);
  graph->addEdge(r1);
  graph->addEdge(r2);
  graph->addEdge(r3);
  graph->addEdge(r4);
  graph->addEdge(d);
  graph->solveCircuit();
  bool err = false;
  err |= !testEquals(8.595, v1.getVoltage().evaluate());
  err |= !testEquals(8.006, v2.getVoltage().evaluate());
  err |= !testEquals(337.2e-6, d->getCurrent().evaluate());
  if (!err)
    std::cout << "Test Passed!" << std::endl;
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
    std::cout << "All tests passed!" << std::endl;
  else
    std::cout << "Tests failed. See above for details" << std::endl;
}
