#include "api.h"

#include <cstddef>
#include <memory>

#include "circuitGraph.h"
#include "circuitGraphMessage.pb.h"

bool processGraph(void* inputBuffer, size_t inputLength, void** outputBuffer,
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
  *outputBuffer = malloc(*outputLength);
  return output.SerializeToArray(*outputBuffer, *outputLength);
}

void freeGraph(void* graph) { free(graph); }
