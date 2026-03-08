#include "circuit_solver/api.h"

#include <google/protobuf/util/json_util.h>

#include <cstddef>
#include <cstring>
#include <memory>
#include <sstream>
#include <stdexcept>

#include "circuit_solver/circuitGraph.h"
#include "circuit_solver/proto.h"

proto::CircuitGraph solveCircuit(proto::CircuitGraph input) {
  std::optional<std::unique_ptr<CircuitGraph>> optionalCircuitGraph =
      CircuitGraph::fromProto(input);
  if (!optionalCircuitGraph.has_value()) {
    throw std::invalid_argument(
        "Protobuf did not match the expected schema for a circuit graph");
  }
  std::unique_ptr<CircuitGraph> circuitGraph =
      std::move(optionalCircuitGraph.value());
  bool solved = circuitGraph->solveCircuit();
  if (!solved) {
    throw NoSolutionException("No solution found");
  }
  return circuitGraph->toProto();
}

int solveGraphFromBuffer(void* inputBuffer, size_t inputLength,
                         void** outputBuffer, size_t* outputLength) {
  proto::CircuitGraph message;
  bool success = message.ParseFromArray(inputBuffer, inputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  proto::CircuitGraph output;
  try {
    output = solveCircuit(message);
  } catch (std::invalid_argument) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  } catch (NoSolutionException) {
    return CIRCUITSOLVER_ERROR_NO_SOLUTION;
  }
  *outputLength = output.ByteSizeLong();
  *outputBuffer = operator new(*outputLength);
  success = output.SerializeToArray(*outputBuffer, *outputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  return 0;
}

int solveGraphFromJson(char* inputJson, char** outputJson) {
  proto::CircuitGraph message;
  auto status =
      google::protobuf::json::JsonStringToMessage(inputJson, &message);
  if (!status.ok()) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  proto::CircuitGraph output;
  try {
    output = solveCircuit(message);
  } catch (std::invalid_argument) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  } catch (NoSolutionException) {
    return CIRCUITSOLVER_ERROR_NO_SOLUTION;
  }
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

std::string solveGraphFromJson(std::string inputJson) {
  proto::CircuitGraph message;
  auto status =
      google::protobuf::json::JsonStringToMessage(inputJson, &message);
  if (!status.ok()) {
    std::stringstream ss;
    ss << "Invalid input json: " << inputJson;
    throw std::invalid_argument(ss.str());
  }
  proto::CircuitGraph output;
  // No catching logic here - we want the user to be able to catch and see any
  // errors themselves
  output = solveCircuit(message);

  std::string outputString;
  status = google::protobuf::json::MessageToJsonString(output, &outputString);
  if (!status.ok()) {
    throw FailedSerializationException(
        "Could not serialize the solved circuit");
  }
  // std::string makes no guarantees about heap allocation so we need to copy to
  // our own heap-allocated char buffer
  return outputString;
}

std::string solveGraphFromString(std::string inputString) {
  proto::CircuitGraph message;
  bool success = message.ParseFromString(inputString);
  if (!success) {
    throw std::invalid_argument("Could not parse input data");
  }
  proto::CircuitGraph output;
  output = solveCircuit(message);
  std::string outputString;
  success = output.SerializeToString(&outputString);
  if (!success) {
    throw FailedSerializationException("Failed serialization");
  }
  return outputString;
}

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
