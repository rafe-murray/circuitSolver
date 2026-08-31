#pragma once
#include <gmock/gmock.h>

#include <expected>
#include <functional>

#include "circuit_solver/circuitGraph.h"
#include "circuit_solver/errors.h"
class MockCircuitGraph : public CircuitGraph {
 public:
  // NOLINTBEGIN(modernize-use-trailing-return-type)
  MOCK_METHOD((std::expected<std::reference_wrapper<CircuitGraph>,
                             circuitsolver::CircuitSolverError>),
              solveCircuit, ());
  // NOLINTEND(modernize-use-trailing-return-type)
};
