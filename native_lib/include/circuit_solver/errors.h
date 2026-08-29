#pragma once
#include <cstdint>
#include <string>
#include <string_view>

#include "circuit_solver/c_errors.h"

namespace circuitsolver {
enum class ErrorType : int8_t {
  NoSolution = CIRCUITSOLVER_ERROR_NO_SOLUTION,
  FailedSerialization = CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION,
  InvalidInput = CIRCUITSOLVER_ERROR_INVALID_INPUT,
  TooManyDiscontinuities = CIRCUITSOLVER_ERROR_TOO_MANY_DISCONTINUITIES,
};

class CircuitSolverError {
  // TODO: add helper constructors
  // TODO: make message optional

 public:
  explicit CircuitSolverError(ErrorType type, std::string_view message);

  [[nodiscard]] auto message() const -> std::string;
  [[nodiscard]] auto type() const -> ErrorType;

 private:
  ErrorType _type;
  std::string _message;
};

}  // namespace circuitsolver
