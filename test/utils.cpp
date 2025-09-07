#include "utils.h"

#include <absl/status/status.h>
#include <google/protobuf/util/json_util.h>

#include <exception>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <streambuf>

#include "circuitGraphMessage.pb.h"

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

circuitsolver::CircuitGraphMessage GetMessageFromJsonFile(
    const char* filename) {
  circuitsolver::CircuitGraphMessage cgm;
  FILE* infile = fopen("001-unsolved.json", "r");
  std::string jsonMessage;
  char* buf;
  size_t len;
  do {
    buf = fgetln(infile, &len);
    jsonMessage.append(buf, len);
  } while (buf != nullptr);
  if (!feof(infile)) {
    std::ostringstream buf;
    buf << "Finished reading lines from " << filename
        << " but did not reach EOF";
    throw std::runtime_error(buf.str());
  };
  if (ferror(infile)) {
    std::ostringstream buf;
    buf << "Encountered an error while reading " << filename;
    throw std::runtime_error(buf.str());
  }
  absl::Status status =
      google::protobuf::json::JsonStringToMessage(jsonMessage, &cgm);
  if (!status.ok()) {
    std::ostringstream buf;
    buf << "Could not convert JSON string to protobuf message";
    throw std::runtime_error(buf.str());
  }
  return cgm;
}
