#include <google/protobuf/json/json.h>
#include <google/protobuf/message.h>
#include <google/protobuf/util/message_differencer.h>
#include <gtest/gtest.h>

#include <string>

#include "circuit_solver/api.h"
#include "test/utils.h"

using circuitsolver::solveCircuit;
using circuitsolver::solveGraphFromJson;
using circuitsolver::solveGraphFromString;
using google::protobuf::json::MessageToJsonString;
using google::protobuf::util::MessageDifferencer;

TEST(CppApiTest, fromProtoMessage) {
  auto cgmUnsolved = GetMessageFromJsonFile("001-unsolved.json");
  auto result = solveCircuit(cgmUnsolved);
  EXPECT_TRUE(result.has_value()) << result.error().message();
  auto expected = GetMessageFromJsonFile("001-solved.json");
  EXPECT_PRED_FORMAT2(IsEqual, result.value(), expected);
}
TEST(CppApiTest, fromString) {
  auto cgmUnsolved = GetMessageFromJsonFile("001-unsolved.json");
  auto result = solveGraphFromString(cgmUnsolved.SerializeAsString());
  EXPECT_TRUE(result.has_value()) << result.error().message();
  auto actual = proto::CircuitGraph{};
  ASSERT_TRUE(actual.ParseFromString(result.value()));
  auto expected = GetMessageFromJsonFile("001-solved.json");
  EXPECT_PRED_FORMAT2(IsEqual, actual, expected);
}
TEST(CppApiTest, fromJson) {
  auto cgmUnsolved = GetMessageFromJsonFile("001-unsolved.json");
  std::string jsonInput{};
  auto status = MessageToJsonString(cgmUnsolved, &jsonInput);
  ASSERT_TRUE(status.ok());
  auto result = solveGraphFromJson(jsonInput);
  EXPECT_TRUE(result.has_value()) << result.error().message();
  auto actual = proto::CircuitGraph{};
  ASSERT_TRUE(
      google::protobuf::json::JsonStringToMessage(result.value(), &actual)
          .ok());
  auto expected = GetMessageFromJsonFile("001-solved.json");
  EXPECT_PRED_FORMAT2(IsEqual, actual, expected);
}
