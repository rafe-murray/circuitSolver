#ifndef CIRCUITSOLVER_API_H
#define CIRCUITSOLVER_API_H

#include <cstddef>

#define EXPORT extern "C"

// NOLINTBEGIN(modernize-*,cppcoreguidelines-macro-usage)
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

// NOLINTEND(modernize-*,cppcoreguidelines-macro-usage)

// C++ bindings
#ifdef __cplusplus
#include <expected>
#include <string>
#include <string_view>

#include "circuit_solver/proto.h"

namespace circuitsolver {

enum class ErrorType : int8_t {
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
  ErrorType _type;
  std::string _message;
};

auto solveCircuit(const proto::CircuitGraph& input)
    -> std::expected<proto::CircuitGraph, CircuitSolverError>;

// Gets and returns a string version of a protocol buffer
auto solveGraphFromString(std::string_view input)
    -> std::expected<std::string, CircuitSolverError>;

auto solveGraphFromJson(std::string_view input)
    -> std::expected<std::string, CircuitSolverError>;

}  // namespace circuitsolver

#endif  // __cplusplus
#endif  // CIRCUITSOLVER_API_H
