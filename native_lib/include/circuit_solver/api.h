#pragma once

#include <cstddef>
#include <expected>
#define EXPORT extern "C"

// Blocking call for now
EXPORT
int solveGraphFromBuffer(void* inputBuffer, size_t inputLength,
                         void** outputBuffer, size_t* outputLength);

EXPORT
void destroyGraphBuffer(void* graphBuffer);

EXPORT
void destroyGraphJson(char* graphJson);

EXPORT
int solveGraphFromJson(char* inputJson, char** outputJson);

EXPORT
const char* getErrorMessage(int errorNumber);

#define CIRCUITSOLVER_ERROR_INVALID_INPUT 1
#define CIRCUITSOLVER_ERROR_NO_SOLUTION 2
#define CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION 3

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

  std::string message() const;
  ErrorType type() const;

 private:
  const ErrorType _type;
  const std::string _message;
};

std::expected<proto::CircuitGraph, CircuitSolverError> solveCircuit(
    proto::CircuitGraph input);

// Gets and returns a string version of a protocol buffer
std::expected<std::string, CircuitSolverError> solveGraphFromString(
    std::string inputString);
std::expected<std::string, CircuitSolverError> solveGraphFromJson(
    std::string inputJson);

}  // namespace circuitsolver

#endif
