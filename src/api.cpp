#include "api.h"

#include <cstddef>
#include <memory>
#include <string_view>

#include "circuitGraph.h"
#include "circuitGraphMessage.pb.h"

int processGraph(void* inputBuffer, size_t inputLength, void** outputBuffer,
                 size_t* outputLength) {
  circuitsolver::CircuitGraphMessage message;
  message.ParseFromArray(inputBuffer, inputLength);
  std::optional<std::unique_ptr<CircuitGraph>> optionalCircuitGraph =
      CircuitGraph::fromProto(message);
  if (!optionalCircuitGraph.has_value()) {
    return false;
  }
  std::unique_ptr<CircuitGraph> circuitGraph =
      std::move(optionalCircuitGraph.value());
  circuitGraph->solveCircuit();
  circuitsolver::CircuitGraphMessage output = circuitGraph->toProto();
  *outputLength = output.ByteSizeLong();
  *outputBuffer = operator new(*outputLength);
  output.SerializeToArray(*outputBuffer, *outputLength);
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
      {CIRCUITSOLVER_ERROR_BAD_ALLOC, "Bad allocation"},
  };
  auto it = errorMessages.find(errorNumber);
  if (it != errorMessages.end()) {
    return it->second;
  } else {
    return "Unknown error";
  }
}
