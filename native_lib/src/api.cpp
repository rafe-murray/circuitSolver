#include "api.h"

#include <google/protobuf/util/json_util.h>

#include <cstddef>
#include <cstring>
#include <memory>

#include "circuitGraph.h"
#include "proto.h"

int solveCircuit(proto::CircuitGraph input, proto::CircuitGraph& output) {
  std::optional<std::unique_ptr<CircuitGraph>> optionalCircuitGraph =
      CircuitGraph::fromProto(input);
  if (!optionalCircuitGraph.has_value()) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  std::unique_ptr<CircuitGraph> circuitGraph =
      std::move(optionalCircuitGraph.value());
  bool solved = circuitGraph->solveCircuit();
  if (!solved) {
    return CIRCUITSOLVER_ERROR_NO_SOLUTION;
  }
  output = circuitGraph->toProto();
  return 0;
}

int solveGraphFromBuffer(void* inputBuffer, size_t inputLength,
                         void** outputBuffer, size_t* outputLength) {
  proto::CircuitGraph message;
  bool success = message.ParseFromArray(inputBuffer, inputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  proto::CircuitGraph output;
  int error = solveCircuit(message, output);
  if (error) {
    return error;
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
  int error = solveCircuit(message, output);
  if (error) {
    return error;
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
