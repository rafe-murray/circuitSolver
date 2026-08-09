#ifndef CIRCUITSOLVER_API_H
#define CIRCUITSOLVER_API_H

#ifdef __cplusplus
#include <cstddef>
#define EXPORT extern "C"
#else
#define EXPORT
#endif

// NOLINTBEGIN(modernize-*,cppcoreguidelines-macro-usage)

/**
 * Solves the circuit in `inputBuffer`
 *
 * The inputBuffer should be a protobuf data buffer for a CircuitGraphMessage.
 * If the circuit is successfully solved, `outputBuffer` will contain a
 * protobuf-serialized CircuitGraphMessage with the solution, and outputLength
 * will contain the size of that buffer. These values are only valid if the
 * return value is 0
 * @param inputBuffer a buffer containing a protobuf-serialized
 * CircuitGraphMessage representing the circuit to solve
 * @param inputLength length of the input buffer
 * @param outputBuffer pointer to the buffer to store the output in. This
 * buffer is owned by circuitsolver. Call `destroyGraphBuffer()` to free it
 * @param outputLength pointer to variable to store the length of the output
 * buffer in
 * @return 0 on success, or an error code on failure. To get a human readable
 * message use `getErrorMessage(errno)`
 */
EXPORT
int solveGraphFromBuffer(void* inputBuffer, int inputLength,
                         void** outputBuffer, int* outputLength);

/**
 * Frees the memory associated with a __returned__ CircuitGraphMessage buffer
 *
 * This will crash if a JSON buffer is passed in or any pointer not managed by
 * circuitsolver
 * @param graphBuffer the buffer to free
 */
EXPORT
void destroyGraphBuffer(void* graphBuffer);

/**
 * Frees the memory associated with the JSON graph
 *
 * This will crash if the JSON string is not managed by circuitsolver
 * @param graphJson the string to free
 */
EXPORT
void destroyGraphJson(const char* graphJson);

/**
 * Solves the circuit in `inputBuffer`
 *
 * The inputBuffer should be a protobuf data buffer for a CircuitGraphMessage.
 * If the circuit is successfully solved, `outputBuffer` will contain a
 * protobuf-serialized CircuitGraphMessage with the solution, and outputLength
 * will contain the size of that buffer. These values are only valid if the
 * return value is 0
 * @param inputJson a string containing a protobuf json serialized
 * CircuitGraphMessage representing the circuit to solve. This accepts the
 * canonical json representation provided by the protobuf parser - other
 * serializations my work but no guarantees are made
 * @param outputJson pointer to the string to store the output in. This string
 * is owned by circuitsolver. Call `destroyGraphBuffer()` to free it
 * @return 0 on success, or an error code on failure. To get a human readable
 * message use `getErrorMessage(errno)`
 */
EXPORT
int solveGraphFromJson(const char* inputJson, char** outputJson);

/**
 * Get a human readable message given an error number
 *
 * @param errorNumber error number returned from a circuitsolver request
 * @return An error message. This is a compile time constant string that should
 * not be freed
 */
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

#include "circuit_solver/errors.h"
#include "circuit_solver/proto.h"

namespace circuitsolver {
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
