#include "circuit_solver/api.h"

#include <absl/status/status.h>
#include <fmt/format.h>
#include <google/protobuf/util/json_util.h>

#include <cstddef>
#include <cstring>
#include <expected>
#include <limits>
#include <memory>
#include <string_view>
#include <utility>

#include "circuit_solver/circuitGraph.h"
#include "circuit_solver/proto.h"

void destroyGraphBuffer(void* graphBuffer) { operator delete(graphBuffer); }
// NOLINTBEGIN(cppcoreguidelines-owning-memory)
void destroyGraphJson(const char* graphJson) { delete[] graphJson; }
// NOLINTEND(cppcoreguidelines-owning-memory)

auto getErrorMessage(int errorNumber) -> const char* {
  const std::unordered_map<int, const char*> errorMessages = {
      {CIRCUITSOLVER_ERROR_INVALID_INPUT, "Invalid input"},
      {CIRCUITSOLVER_ERROR_NO_SOLUTION, "No solution"},
      {CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION, "Failed serialization"},
  };
  auto it = errorMessages.find(errorNumber);
  if (it != errorMessages.end()) {
    return it->second;
  }
  return "Unknown error";
}

auto solveGraphFromBuffer(void* inputBuffer, int inputLength,
                          void** outputBuffer, int* outputLength) -> int {
  using namespace circuitsolver;
  proto::CircuitGraph message;
  bool success = message.ParseFromArray(inputBuffer, inputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  auto maybeOutput = solveCircuit(message);
  if (!maybeOutput) {
    const auto& error = maybeOutput.error();
    return std::to_underlying(error.type());
  }
  const auto& output = maybeOutput.value();
  size_t length = output.ByteSizeLong();
  if (length > std::numeric_limits<int>::max()) {
    // Message was too big
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  *outputLength = static_cast<int>(length);
  *outputBuffer = operator new(*outputLength);
  success = output.SerializeToArray(*outputBuffer, *outputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  return 0;
}

auto solveGraphFromJson(const char* inputJson, char** outputJson) -> int {
  using namespace circuitsolver;
  proto::CircuitGraph message;
  auto status =
      google::protobuf::json::JsonStringToMessage(inputJson, &message);
  if (!status.ok()) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  auto maybeOutput = solveCircuit(message);
  if (!maybeOutput) {
    const auto& error = maybeOutput.error();
    return std::to_underlying(error.type());
  }
  const auto& output = maybeOutput.value();
  std::string outputString;
  status = google::protobuf::json::MessageToJsonString(output, &outputString);
  if (!status.ok()) {
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  // std::string makes no guarantees about heap allocation so we need to copy to
  // our own heap-allocated char buffer
  // NOLINTBEGIN(cppcoreguidelines-owning-memory)
  *outputJson = new char[outputString.size()];
  // NOLINTEND(cppcoreguidelines-owning-memory)
  memcpy(*outputJson, outputString.c_str(), outputString.size());
  return 0;
}

namespace circuitsolver {

CircuitSolverError::CircuitSolverError(ErrorType type, std::string_view message)
    : _type(type), _message(message) {}

auto CircuitSolverError::message() const -> std::string { return _message; }
auto CircuitSolverError::type() const -> ErrorType { return _type; }

auto solveCircuit(const proto::CircuitGraph& input)
    -> std::expected<proto::CircuitGraph, CircuitSolverError> {
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
auto solveGraphFromJson(std::string_view input)
    -> std::expected<std::string, CircuitSolverError> {
  proto::CircuitGraph message;
  auto status = google::protobuf::json::JsonStringToMessage(input, &message);
  if (!status.ok()) {
    return std::unexpected{CircuitSolverError{
        ErrorType::InvalidInput, fmt::format("Invalid input json: {}", input)}};
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

auto solveGraphFromString(std::string_view input)
    -> std::expected<std::string, CircuitSolverError> {
  proto::CircuitGraph message;
  bool success = message.ParseFromString(input);
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
