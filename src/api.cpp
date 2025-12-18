#include "api.h"

#include <cstddef>
#include <memory>

#include "circuitGraph.h"
#include "proto.h"

int processGraph(void* inputBuffer, size_t inputLength, void** outputBuffer,
                 size_t* outputLength) {
  proto::CircuitGraph message;
  bool success = message.ParseFromArray(inputBuffer, inputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  std::optional<std::unique_ptr<CircuitGraph>> optionalCircuitGraph =
      CircuitGraph::fromProto(message);
  if (!optionalCircuitGraph.has_value()) {
    return CIRCUITSOLVER_ERROR_INVALID_INPUT;
  }
  std::unique_ptr<CircuitGraph> circuitGraph =
      std::move(optionalCircuitGraph.value());
  bool solved = circuitGraph->solveCircuit();
  if (!solved) {
    return CIRCUITSOLVER_ERROR_NO_SOLUTION;
  }
  proto::CircuitGraph output = circuitGraph->toProto();
  *outputLength = output.ByteSizeLong();
  *outputBuffer = operator new(*outputLength);
  success = output.SerializeToArray(*outputBuffer, *outputLength);
  if (!success) {
    return CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION;
  }
  return 0;
}

int destroyGraph(void* graph) {
  operator delete(graph);
  return 0;
}
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
