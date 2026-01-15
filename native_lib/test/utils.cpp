#include "utils.h"

#include <absl/status/status.h>
#include <google/protobuf/util/json_util.h>

#include <filesystem>
#include <fstream>
#include <sstream>
#include <stdexcept>

#include "src/proto.h"

testing::AssertionResult IsWithinRelativeTolerance(double expected,
                                                   double actual, double tol) {
  bool succeeded;
  if (expected == 0) {
    succeeded = fabs(expected - actual) <= tol;
  } else {
    succeeded = fabs(expected - actual) / fabs(expected) <= tol;
  }
  if (succeeded) {
    return testing::AssertionSuccess();
  } else {
    return testing::AssertionFailure()
           << "Expected " << expected << " but got " << actual
           << " which was not within the relative tolerance of " << tol;
  }
}

proto::CircuitGraph GetMessageFromJsonFile(const char* filename) {
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

uuids::uuid_random_generator getUuidGenerator() {
  std::random_device rd;
  auto seed_data = std::array<int, std::mt19937::state_size>{};
  std::generate(std::begin(seed_data), std::end(seed_data), std::ref(rd));
  std::seed_seq seq(std::begin(seed_data), std::end(seed_data));
  std::mt19937 generator(seq);
  uuids::uuid_random_generator gen{generator};
  return gen;
}
