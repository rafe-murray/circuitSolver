#include "utils.h"

#include <absl/status/status.h>
#include <google/protobuf/json/json.h>
#include <google/protobuf/util/json_util.h>
#include <google/protobuf/util/message_differencer.h>
#include <stduuid/uuid.h>

#include <algorithm>
#include <array>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iterator>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>

#include "circuit_solver/proto.h"
#include "gtest/gtest.h"

using google::protobuf::json::MessageToJsonString;
using google::protobuf::util::MessageDifferencer;

auto IsEqual(const char* actualExpression, const char* expectedExpression,
             const proto::CircuitGraph& actual,
             const proto::CircuitGraph& expected) -> testing::AssertionResult {
  bool equal = MessageDifferencer::Equals(actual, expected);
  if (equal) {
    return testing::AssertionSuccess();
  }
  std::string actualJson{};
  std::string expectedJson{};
  (void)MessageToJsonString(actual, &actualJson);
  (void)MessageToJsonString(expected, &expectedJson);
  return testing::AssertionFailure() << "Value of: IsEqual(" << actualExpression
                                     << ", " << expectedExpression << ")\n"
                                     << "  Actual: " << actualJson << "\n"
                                     << "  Expected: " << expectedJson;
}

auto IsWithinRelativeTolerance(double expected, double actual, double tol)
    -> testing::AssertionResult {
  bool succeeded{};
  if (expected == 0) {
    succeeded = fabs(expected - actual) <= tol;
  } else {
    succeeded = fabs(expected - actual) / fabs(expected) <= tol;
  }
  if (succeeded) {
    return testing::AssertionSuccess();
  }
  return testing::AssertionFailure()
         << "Expected " << expected << " but got " << actual
         << " which was not within the relative tolerance of " << tol;
}

auto GetMessageFromJsonFile(const char* filename) -> proto::CircuitGraph {
  proto::CircuitGraph cgm;
  std::filesystem::path filePath =
      std::filesystem::path(TEST_DATA_DIR) / filename;
  std::ifstream ifs(filePath);

  std::string content((std::istreambuf_iterator<char>(ifs)),
                      std::istreambuf_iterator<char>());
  absl::Status status =
      google::protobuf::json::JsonStringToMessage(content, &cgm);
  if (!status.ok()) {
    std::ostringstream buf;
    buf << "Could not convert JSON string to protobuf message";
    throw std::runtime_error(buf.str());
  }
  return cgm;
}

auto getUuidGenerator() -> uuids::uuid_random_generator {
  std::random_device rd;
  auto seed_data = std::array<int, std::mt19937::state_size>{};
  std::ranges::generate(seed_data, std::ref(rd));
  std::seed_seq seq(std::begin(seed_data), std::end(seed_data));
  std::mt19937 generator(seq);
  uuids::uuid_random_generator gen{generator};
  return gen;
}
