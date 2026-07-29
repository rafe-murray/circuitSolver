#include "circuit_solver/api.h"

#include <absl/status/status.h>
#include <google/protobuf/util/json_util.h>

#include <cstddef>
#include <cstring>
#include <expected>
#include <format>
#include <limits>
#include <memory>
#include <utility>

#include "circuit_solver/circuitGraph.h"
#include "circuit_solver/proto.h"

void destroyGraphBuffer(void* graphBuffer) { operator delete(graphBuffer); }
void destroyGraphJson(char* graphJson) { delete[] graphJson; }

const char* getErrorMessage(int errorNumber) {
  const std::unordered_map<int, const char*> errorMessages = {
      {CIRCUITSOLVER_ERROR_INVALID_INPUT, "Invalid input"},
      {CIRCUITSOLVER_ERROR_NO_SOLUTION, "No solution"},
      {CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION, "Failed serialization"},
  };
  auto it = errorMessages.find(errorNumber);
  if (it != errorMessages.end()) {
    return it->second;
  } else {
    return "Unknown error";
  }
}

int solveGraphFromBuffer(void* inputBuffer, int inputLength,
                         void** outputBuffer, int* outputLength) {
  using namespace circuitsolver;
  proto::CircuitGraph message;
  bool success = message.ParseFromArray(inputBuffer, inputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  auto maybeOutput = solveCircuit(message);
  if (!maybeOutput) {
    auto error = maybeOutput.error();
    return std::to_underlying(error.type());
  }
  auto output = maybeOutput.value();
  size_t length = output.ByteSizeLong();
  if (length > std::numeric_limits<int>::max()) {
    // Message was too big
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  *outputLength = (int)length;
  *outputBuffer = operator new(*outputLength);
  success = output.SerializeToArray(*outputBuffer, *outputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  return 0;
}

int solveGraphFromJson(char* inputJson, char** outputJson) {
  using namespace circuitsolver;
  proto::CircuitGraph message;
  auto status =
      google::protobuf::json::JsonStringToMessage(inputJson, &message);
  if (!status.ok()) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  auto maybeOutput = solveCircuit(message);
  if (!maybeOutput) {
    auto error = maybeOutput.error();
    return std::to_underlying(error.type());
  }
  auto output = maybeOutput.value();
  std::string outputString;
  status = google::protobuf::json::MessageToJsonString(output, &outputString);
  if (!status.ok()) {
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  // std::string makes no guarantees about heap allocation so we need to copy to
  // our own heap-allocated char buffer
  *outputJson = new char[outputString.size()];
  memcpy(*outputJson, outputString.c_str(), outputString.size());
  return 0;
}

namespace circuitsolver {

CircuitSolverError::CircuitSolverError(ErrorType type, std::string_view message)
    : _type(type), _message(message) {}

std::string CircuitSolverError::message() const { return _message; }
ErrorType CircuitSolverError::type() const { return _type; }

std::expected<proto::CircuitGraph, CircuitSolverError> solveCircuit(
    proto::CircuitGraph input) {
  std::optional<std::unique_ptr<CircuitGraph>> optionalCircuitGraph =
      CircuitGraph::fromProto(input);
  if (!optionalCircuitGraph.has_value()) {
    return std::unexpected{CircuitSolverError{
        ErrorType::InvalidInput,
        "Protobuf did not match the expected schema for a circuit graph"}};
  }
  std::unique_ptr<CircuitGraph> circuitGraph =
      std::move(optionalCircuitGraph.value());
  bool solved = circuitGraph->solveCircuit();
  if (!solved) {
    return std::unexpected{
        CircuitSolverError{ErrorType::NoSolution, "No solution found"}};
  }
  return circuitGraph->toProto();
}
std::expected<std::string, CircuitSolverError> solveGraphFromJson(
    std::string inputJson) {
  proto::CircuitGraph message;
  auto status =
      google::protobuf::json::JsonStringToMessage(inputJson, &message);
  if (!status.ok()) {
    return std::unexpected{
        CircuitSolverError{ErrorType::InvalidInput,
                           std::format("Invalid input json: {}", inputJson)}};
  }
  auto maybeOutput = solveCircuit(message);
  if (!maybeOutput) {
    return std::unexpected{maybeOutput.error()};
  }
  auto output = maybeOutput.value();

  std::string outputString;
  status = google::protobuf::json::MessageToJsonString(output, &outputString);
  if (!status.ok()) {
    return std::unexpected{
        CircuitSolverError{ErrorType::FailedSerialization,
                           "Could not serialize the solved circuit"}};
  }
  return outputString;
}

std::expected<std::string, CircuitSolverError> solveGraphFromString(
    std::string inputString) {
  proto::CircuitGraph message;
  bool success = message.ParseFromString(inputString);
  if (!success) {
    return std::unexpected{
        CircuitSolverError{
            ErrorType::InvalidInput,
            "Could not parse input data",
        },
    };
  }
  auto maybeOutput = solveCircuit(message);
  if (!maybeOutput) {
    return std::unexpected{maybeOutput.error()};
  }
  auto output = maybeOutput.value();
  std::string outputString;
  success = output.SerializeToString(&outputString);
  if (!success) {
    return std::unexpected{CircuitSolverError{ErrorType::FailedSerialization,
                                              "Failed serialization"}};
  }
  return outputString;
}

}  // namespace circuitsolver
