#include <gtest/gtest.h>

#include "src/branch.h"
#include "src/circuitGraph.h"
#include "utils.h"

TEST(CircuitTest, BuildBasicCircuit) {
  CircuitGraph cg;
  Vertex ref(0, 0);
  Vertex v1(1);
  Vertex v2(2);
  Edge vs = Edge(0, VoltageSource(ref, v1, 5));
  Edge r1 = Edge(1, Resistor(v1, v2, 2));
  Edge r2 = Edge(2, Resistor(v2, ref, 3));
  EXPECT_TRUE(cg.addVertex(ref));
  EXPECT_TRUE(cg.addVertex(v1));
  EXPECT_TRUE(cg.addVertex(v2));
  EXPECT_TRUE(cg.addEdge(vs));
  EXPECT_TRUE(cg.addEdge(r1));
  EXPECT_TRUE(cg.addEdge(r2));
  auto summary = cg.solveCircuit();
  ASSERT_TRUE(summary.IsSolutionUsable());
  EXPECT_EQ(ref.getVoltage().evaluate(), 0);
  EXPECT_EQ(v1.getVoltage().evaluate(), 5);
  EXPECT_EQ(v2.getVoltage().evaluate(), 3);
  EXPECT_EQ(vs.getCurrent().evaluate(), 1);
  EXPECT_EQ(r1.getCurrent().evaluate(), 1);
  EXPECT_EQ(r2.getCurrent().evaluate(), 1);
}

TEST(CircuitTest, RealDiode) {
  CircuitGraph cg;
  Vertex ref(0, 0);
  Vertex v1(1);
  Vertex v2(2);
  Vertex vcc(3, 15);
  Edge d(0, RealDiode(v1, v2, 50e-12, 1.5, 25e-3));
  Edge r1(1, Resistor(vcc, v1, 2000));
  Edge r2(2, Resistor(vcc, v2, 3000));
  Edge r3(3, Resistor(v1, ref, 3000));
  Edge r4(4, Resistor(v2, ref, 3000));
  EXPECT_TRUE(cg.addVertex(ref));
  EXPECT_TRUE(cg.addVertex(v1));
  EXPECT_TRUE(cg.addVertex(v2));
  EXPECT_TRUE(cg.addVertex(vcc));

  EXPECT_TRUE(cg.addEdge(d));
  EXPECT_TRUE(cg.addEdge(r1));
  EXPECT_TRUE(cg.addEdge(r2));
  EXPECT_TRUE(cg.addEdge(r3));
  EXPECT_TRUE(cg.addEdge(r4));

  auto summary = cg.solveCircuit();
  ASSERT_TRUE(summary.IsSolutionUsable());
  EXPECT_TRUE(IsWithinRelativeTolerance(8.595, v1.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(8.006, v2.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(337.17e-6, d.getCurrent().evaluate()));
}

TEST(CircuitTest, BasicCircuitFromProtobuf) {}

TEST(CircuitTest, LargeCircuit) {}
