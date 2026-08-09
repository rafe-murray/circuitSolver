#include "circuit_solver/api.h"

#include <gtest/gtest.h>
#include <stduuid/uuid.h>

#include <utility>

#include "circuit_solver/proto.h"
#include "circuit_solver/v1alpha1/circuit_graph_message.pb.h"
#include "circuit_solver/vertex.h"
#include "test/utils.h"

TEST(ApiTest, EdgesKeepIds) {
  proto::CircuitGraph cg;
  auto gen = getUuidGenerator();
  uuids::uuid vertexId0 = gen();
  uuids::uuid vertexId1 = gen();
  uuids::uuid vertexId2 = gen();
  uuids::uuid edgeId0 = gen();
  uuids::uuid edgeId1 = gen();
  uuids::uuid edgeId2 = gen();

  proto::Vertex ref{};
  ref.set_id(uuids::to_string(vertexId0));
  ref.set_voltage(0);

  proto::Vertex v1{};
  v1.set_id(uuids::to_string(vertexId1));

  proto::Vertex v2{};
  v2.set_id(uuids::to_string(vertexId2));

  proto::Edge vs{};
  vs.set_id(uuids::to_string(edgeId0));
  vs.set_from_id(ref.id());
  vs.set_to_id(v1.id());
  auto voltageSource =
      new circuit_solver::v1alpha1::CircuitGraphMessage::Edge::VoltageSource{};
  voltageSource->set_voltage(5);
  vs.set_allocated_voltage_source(voltageSource);

  proto::Edge r1{};
  r1.set_id(uuids::to_string(edgeId1));
  r1.set_from_id(v1.id());
  r1.set_to_id(v2.id());
  auto resistor1 =
      new circuit_solver::v1alpha1::CircuitGraphMessage::Edge::Resistor{};
  resistor1->set_resistance(2);
  r1.set_allocated_resistor(resistor1);

  proto::Edge r2{};
  r2.set_id(uuids::to_string(edgeId2));
  r2.set_from_id(v2.id());
  r2.set_to_id(ref.id());
  auto resistor2 =
      new circuit_solver::v1alpha1::CircuitGraphMessage::Edge::Resistor{};
  resistor2->set_resistance(3);
  r2.set_allocated_resistor(resistor2);

  cg.mutable_vertices()->emplace(std::pair{ref.id(), ref});
  cg.mutable_vertices()->emplace(std::pair{v1.id(), v1});
  cg.mutable_vertices()->emplace(std::pair{v2.id(), v2});

  cg.mutable_edges()->emplace(std::pair{vs.id(), vs});
  cg.mutable_edges()->emplace(std::pair{r1.id(), r1});
  cg.mutable_edges()->emplace(std::pair{r2.id(), r2});

  auto inputBuffer = cg.SerializeAsString();
  void* outputBuffer;
  int outputLength;
  solveGraphFromBuffer((void*)inputBuffer.c_str(), inputBuffer.size(),
                       &outputBuffer, &outputLength);
  auto outputGraph = proto::CircuitGraph();
  outputGraph.ParseFromArray(outputBuffer, outputLength);

  EXPECT_TRUE(outputGraph.edges().at(vs.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(vs.id()).id() !=
              uuids::to_string(edgeId0));
  EXPECT_TRUE(outputGraph.edges().at(r1.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(r1.id()).id() !=
              uuids::to_string(edgeId1));
  EXPECT_TRUE(outputGraph.edges().at(r2.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(r2.id()).id() !=
              uuids::to_string(edgeId2));
}
