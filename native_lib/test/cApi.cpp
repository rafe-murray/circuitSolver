#include <gmock/gmock.h>
#include <google/protobuf/json/json.h>
#include <gtest/gtest.h>
#include <stduuid/uuid.h>

#include <cstddef>
#include <cstring>
#include <string>
#include <utility>

#include "circuit_solver/api.h"
#include "circuit_solver/c_errors.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/v1alpha1/circuit_graph_message.pb.h"
#include "circuit_solver/vertex.h"
#include "test/utils.h"

// This is a C API so we expect non-owning memory references and uninitialized
// variables NOLINTBEGIN(cppcoreguidelines-owning-memory)
// NOLINTBEGIN(cppcoreguidelines-init-variables)

class CApiTest : public ::testing::Test {
 protected:
  // NOLINTBEGIN(cppcoreguidelines-non-private-member-variables-in-classes)
  proto::CircuitGraph cg{};

  proto::Vertex ref{};
  proto::Vertex v1{};
  proto::Vertex v2{};
  proto::Edge vs{};
  proto::Edge r1{};
  proto::Edge r2{};

  uuids::uuid vertexId0;
  uuids::uuid vertexId1;
  uuids::uuid vertexId2;
  uuids::uuid edgeId0;
  uuids::uuid edgeId1;
  uuids::uuid edgeId2;
  // NOLINTEND(cppcoreguidelines-non-private-member-variables-in-classes)

  void SetUp() override {
    auto gen = getUuidGenerator();
    vertexId0 = gen();
    vertexId1 = gen();
    vertexId2 = gen();
    edgeId0 = gen();
    edgeId1 = gen();
    edgeId2 = gen();
    ref.set_id(uuids::to_string(vertexId0));
    ref.set_voltage(0);

    v1.set_id(uuids::to_string(vertexId1));

    v2.set_id(uuids::to_string(vertexId2));

    vs.set_id(uuids::to_string(edgeId0));
    vs.set_from_id(ref.id());
    vs.set_to_id(v1.id());
    auto* voltageSource = new circuit_solver::v1alpha1::CircuitGraphMessage::
        Edge::VoltageSource{};
    voltageSource->set_voltage(5);
    vs.set_allocated_voltage_source(voltageSource);

    r1.set_id(uuids::to_string(edgeId1));
    r1.set_from_id(v1.id());
    r1.set_to_id(v2.id());
    auto* resistor1 =
        new circuit_solver::v1alpha1::CircuitGraphMessage::Edge::Resistor{};
    resistor1->set_resistance(2);
    r1.set_allocated_resistor(resistor1);

    r2.set_id(uuids::to_string(edgeId2));
    r2.set_from_id(v2.id());
    r2.set_to_id(ref.id());
    auto* resistor2 =
        new circuit_solver::v1alpha1::CircuitGraphMessage::Edge::Resistor{};
    resistor2->set_resistance(3);
    r2.set_allocated_resistor(resistor2);

    cg.mutable_vertices()->emplace(std::pair{ref.id(), ref});
    cg.mutable_vertices()->emplace(std::pair{v1.id(), v1});
    cg.mutable_vertices()->emplace(std::pair{v2.id(), v2});

    cg.mutable_edges()->emplace(std::pair{vs.id(), vs});
    cg.mutable_edges()->emplace(std::pair{r1.id(), r1});
    cg.mutable_edges()->emplace(std::pair{r2.id(), r2});
  }
};

TEST_F(CApiTest, EdgesKeepIds) {
  int inputSize = static_cast<int>(cg.ByteSizeLong());
  char* inputBuffer = new char[inputSize];
  EXPECT_TRUE(cg.SerializeToArray(inputBuffer, inputSize));
  void* outputBuffer;
  int outputLength;
  solveGraphFromBuffer(inputBuffer, inputSize, &outputBuffer, &outputLength);
  auto outputGraph = proto::CircuitGraph();
  outputGraph.ParseFromArray(outputBuffer, outputLength);

  EXPECT_TRUE(outputGraph.edges().at(vs.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(vs.id()).id() ==
              uuids::to_string(edgeId0));
  EXPECT_TRUE(outputGraph.edges().at(r1.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(r1.id()).id() ==
              uuids::to_string(edgeId1));
  EXPECT_TRUE(outputGraph.edges().at(r2.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(r2.id()).id() ==
              uuids::to_string(edgeId2));

  EXPECT_NO_THROW(destroyGraphBuffer(outputBuffer));
}

TEST_F(CApiTest, ErrorMessages) {
  EXPECT_STRNE(getErrorMessage(CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION),
               "Unknown error");
  EXPECT_STRNE(getErrorMessage(CIRCUITSOLVER_ERROR_INVALID_INPUT),
               "Unknown error");
  EXPECT_STRNE(getErrorMessage(CIRCUITSOLVER_ERROR_NO_SOLUTION),
               "Unknown error");
  EXPECT_STRNE(getErrorMessage(CIRCUITSOLVER_ERROR_TOO_MANY_DISCONTINUITIES),
               "Unknown error");
}

TEST_F(CApiTest, InvalidInput) {
  int inputSize = 1;
  char* buffer = new char[inputSize];
  void* outputBuffer;
  int outputSize;
  EXPECT_EQ(solveGraphFromBuffer(buffer, inputSize, &outputBuffer, &outputSize),
            CIRCUITSOLVER_ERROR_INVALID_INPUT);
}

TEST_F(CApiTest, WithJson) {
  std::string input{};
  auto status = google::protobuf::json::MessageToJsonString(cg, &input);
  ASSERT_TRUE(status.ok());
  char* outputBuffer;
  EXPECT_EQ(0, solveGraphFromJson(input.c_str(), &outputBuffer));
  auto outputGraph = proto::CircuitGraph();
  status =
      google::protobuf::json::JsonStringToMessage(outputBuffer, &outputGraph);

  EXPECT_TRUE(outputGraph.edges().at(vs.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(vs.id()).id() ==
              uuids::to_string(edgeId0));
  EXPECT_TRUE(outputGraph.edges().at(r1.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(r1.id()).id() ==
              uuids::to_string(edgeId1));
  EXPECT_TRUE(outputGraph.edges().at(r2.id()).id() != "");
  EXPECT_TRUE(outputGraph.edges().at(r2.id()).id() ==
              uuids::to_string(edgeId2));

  EXPECT_NO_THROW(destroyGraphJson(outputBuffer));
}

// NOLINTEND(cppcoreguidelines-init-variables)
// NOLINTEND(cppcoreguidelines-owning-memory)
