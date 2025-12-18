#include <google/protobuf/util/json_util.h>
#include <gtest/gtest.h>
#include <uuid.h>

#include "src/branch.h"
#include "src/circuitGraph.h"
#include "src/proto.h"
#include "utils.h"

TEST(CircuitTest, BuildBasicCircuit) {
  CircuitGraph cg;
  auto gen = getUuidGenerator();
  uuids::uuid vertexId0 = gen();
  uuids::uuid vertexId1 = gen();
  uuids::uuid vertexId2 = gen();
  uuids::uuid edgeId0 = gen();
  uuids::uuid edgeId1 = gen();
  uuids::uuid edgeId2 = gen();
  Vertex ref(vertexId0, 0);
  Vertex v1(vertexId1);
  Vertex v2(vertexId2);
  Edge vs = Edge(edgeId0, VoltageSource(ref, v1, 5));
  Edge r1 = Edge(edgeId1, Resistor(v1, v2, 2));
  Edge r2 = Edge(edgeId2, Resistor(v2, ref, 3));
  EXPECT_TRUE(cg.addVertex(ref));
  EXPECT_TRUE(cg.addVertex(v1));
  EXPECT_TRUE(cg.addVertex(v2));
  EXPECT_TRUE(cg.addEdge(vs));
  EXPECT_TRUE(cg.addEdge(r1));
  EXPECT_TRUE(cg.addEdge(r2));
  ASSERT_TRUE(cg.solveCircuit());
  EXPECT_TRUE(IsWithinRelativeTolerance(ref.getVoltage().evaluate(), 0));
  EXPECT_TRUE(IsWithinRelativeTolerance(5, v1.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(3, v2.getVoltage().evaluate()));
  // TODO: find out why this fails
  EXPECT_TRUE(IsWithinRelativeTolerance(1, vs.getCurrent().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1, r1.getCurrent().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1, r2.getCurrent().evaluate()));
}

TEST(CircuitTest, RealDiode) {
  CircuitGraph cg;
  auto gen = getUuidGenerator();
  uuids::uuid vertexId0 = gen();
  uuids::uuid vertexId1 = gen();
  uuids::uuid vertexId2 = gen();
  uuids::uuid vertexId3 = gen();
  uuids::uuid edgeId0 = gen();
  uuids::uuid edgeId1 = gen();
  uuids::uuid edgeId2 = gen();
  uuids::uuid edgeId3 = gen();
  uuids::uuid edgeId4 = gen();
  Vertex ref(vertexId0, 0);
  Vertex v1(vertexId1);
  Vertex v2(vertexId2);
  Vertex vcc(vertexId3, 15);
  Edge d(edgeId0, RealDiode(v1, v2, 50e-12, 1.5, 25e-3));
  Edge r1(edgeId1, Resistor(vcc, v1, 2000));
  Edge r2(edgeId2, Resistor(vcc, v2, 3000));
  Edge r3(edgeId3, Resistor(v1, ref, 3000));
  Edge r4(edgeId4, Resistor(v2, ref, 3000));
  EXPECT_TRUE(cg.addVertex(ref));
  EXPECT_TRUE(cg.addVertex(v1));
  EXPECT_TRUE(cg.addVertex(v2));
  EXPECT_TRUE(cg.addVertex(vcc));

  EXPECT_TRUE(cg.addEdge(d));
  EXPECT_TRUE(cg.addEdge(r1));
  EXPECT_TRUE(cg.addEdge(r2));
  EXPECT_TRUE(cg.addEdge(r3));
  EXPECT_TRUE(cg.addEdge(r4));

  ASSERT_TRUE(cg.solveCircuit());
  EXPECT_TRUE(IsWithinRelativeTolerance(8.595, v1.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(8.006, v2.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(337.17e-6, d.getCurrent().evaluate()));
}
TEST(CircuitTest, IdealDiode) {
  CircuitGraph cg;
  auto gen = getUuidGenerator();
  uuids::uuid vertexId0 = gen();
  uuids::uuid vertexId1 = gen();
  uuids::uuid vertexId2 = gen();
  uuids::uuid vertexId3 = gen();
  uuids::uuid edgeId0 = gen();
  uuids::uuid edgeId1 = gen();
  uuids::uuid edgeId2 = gen();
  uuids::uuid edgeId3 = gen();
  uuids::uuid edgeId4 = gen();
  Vertex ref(vertexId0, 0);
  Vertex v1(vertexId1);
  Vertex v2(vertexId2);
  Vertex vcc(vertexId3, 15);
  Edge d(edgeId0, IdealDiode(v1, v2, 0.7));
  Edge r1(edgeId1, Resistor(vcc, v1, 2000));
  Edge r2(edgeId2, Resistor(v1, ref, 3000));
  Edge r3(edgeId3, Resistor(vcc, v2, 3000));
  Edge r4(edgeId4, Resistor(v2, ref, 3000));
  EXPECT_TRUE(cg.addVertex(ref));
  EXPECT_TRUE(cg.addVertex(v1));
  EXPECT_TRUE(cg.addVertex(v2));
  EXPECT_TRUE(cg.addVertex(vcc));

  EXPECT_TRUE(cg.addEdge(d));
  EXPECT_TRUE(cg.addEdge(r1));
  EXPECT_TRUE(cg.addEdge(r2));
  EXPECT_TRUE(cg.addEdge(r3));
  EXPECT_TRUE(cg.addEdge(r4));

  ASSERT_TRUE(cg.solveCircuit());
  EXPECT_TRUE(IsWithinRelativeTolerance(25.0 / 3, v1.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(25.0 / 3, v2.getVoltage().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1.0 / 300, r1.getCurrent().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1.0 / 360, r2.getCurrent().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1.0 / 450, r3.getCurrent().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1.0 / 360, r4.getCurrent().evaluate()));
  EXPECT_TRUE(IsWithinRelativeTolerance(1.0 / 1800, d.getCurrent().evaluate()));
}

// TODO: update these files
TEST(CircuitTest, BasicCircuitFromProtobuf) {
  auto cgmUnsolved = GetMessageFromJsonFile("001-unsolved.json");
  auto cgOptionalUnsolved = CircuitGraph::fromProto(cgmUnsolved);
  ASSERT_TRUE(cgOptionalUnsolved.has_value());
  auto cgUnsolved = cgOptionalUnsolved->get();
  ASSERT_TRUE(cgUnsolved->solveCircuit());

  auto cgmSolved = GetMessageFromJsonFile("001-solved.json");
  auto cgOptionalSolved = CircuitGraph::fromProto(cgmSolved);
  ASSERT_TRUE(cgOptionalSolved.has_value());
  auto cgSolved = cgOptionalSolved->get();
  ASSERT_EQ(*cgUnsolved, *cgSolved);
}

// TODO: mock the UUID generation for better consistency
TEST(CircuitTest, BasicCircuitToProtobuf) {
  CircuitGraph cg;
  auto gen = getUuidGenerator();
  uuids::uuid vertexId0 = gen();
  uuids::uuid vertexId1 = gen();
  uuids::uuid vertexId2 = gen();
  uuids::uuid edgeId0 = gen();
  uuids::uuid edgeId1 = gen();
  uuids::uuid edgeId2 = gen();
  Vertex ref(vertexId0, 0);
  Vertex v1(vertexId1);
  Vertex v2(vertexId2);
  Edge vs = Edge(edgeId0, VoltageSource(ref, v1, 5));
  Edge r1 = Edge(edgeId1, Resistor(v1, v2, 2));
  Edge r2 = Edge(edgeId2, Resistor(v2, ref, 3));
  EXPECT_TRUE(cg.addVertex(ref));
  EXPECT_TRUE(cg.addVertex(v1));
  EXPECT_TRUE(cg.addVertex(v2));
  EXPECT_TRUE(cg.addEdge(vs));
  EXPECT_TRUE(cg.addEdge(r1));
  EXPECT_TRUE(cg.addEdge(r2));
  cg.solveCircuit();
  auto buffer = cg.toProto();
  std::string output;
  absl::Status status =
      google::protobuf::json::MessageToJsonString(buffer, &output);
  ASSERT_TRUE(status.ok());
  // std::cout << output << std::endl;
}

TEST(CircuitTest, LargeCircuit) {}
