#pragma once

#include <cstddef>
#include <expected>
#define EXPORT extern "C"

// Blocking call for now
EXPORT
auto solveGraphFromBuffer(void* inputBuffer, size_t inputLength,
                         void** outputBuffer, size_t* outputLength) -> int;

EXPORT
void destroyGraphBuffer(void* graphBuffer);

EXPORT
void destroyGraphJson(const char* graphJson);

EXPORT
auto solveGraphFromJson(const char* inputJson, char** outputJson) -> int;

EXPORT
auto getErrorMessage(int errorNumber) -> const char*;

enum {
CIRCUITSOLVER_ERROR_INVALID_INPUT = 1,
CIRCUITSOLVER_ERROR_NO_SOLUTION = 2,
CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION = 3
};

// C++ bindings
#ifdef __cplusplus
#include <string>

#include "circuit_solver/proto.h"

namespace circuitsolver {

enum class ErrorType : int {
  NoSolution = CIRCUITSOLVER_ERROR_NO_SOLUTION,
  FailedSerialization = CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION,
  InvalidInput = CIRCUITSOLVER_ERROR_INVALID_INPUT,
};

// Class for errors from circuitsolver
class CircuitSolverError {
  // TODO: add helper constructors
  // TODO: make message optional

 public:
  explicit CircuitSolverError(ErrorType type, std::string_view message);

  [[nodiscard]] auto message() const -> std::string;
  [[nodiscard]] auto type() const -> ErrorType;

 private:
  const ErrorType _type;
  const std::string _message;
};

auto solveCircuit(const proto::CircuitGraph& input)
    -> std::expected<proto::CircuitGraph, CircuitSolverError>;

// Gets and returns a string version of a protocol buffer
auto solveGraphFromString(const std::string& inputString)
    -> std::expected<std::string, CircuitSolverError>;
auto solveGraphFromJson(
    std::string inputJson) -> std::expected<std::string, CircuitSolverError>;

}  // namespace circuitsolver

#endif
