/// Pure C redeclaration of the circuitSolverLib extern "C" API.
///
/// This header exists solely so that `dart run ffigen` can parse the public
/// API without needing to process the C++ headers included by the canonical
/// api.h (e.g. <stdexcept>, <string>). It must be kept in sync with
/// native_lib/include/circuit_solver/api.h.
#ifndef CIRCUIT_SOLVER_FFI_H_
#define CIRCUIT_SOLVER_FFI_H_

#include <stddef.h>

// Error codes returned by solveGraphFromBuffer and solveGraphFromJson.
#define CIRCUITSOLVER_ERROR_INVALID_INPUT 1
#define CIRCUITSOLVER_ERROR_NO_SOLUTION 2
#define CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION 3

/// Solves a circuit supplied as a binary protobuf buffer.
///
/// On success returns 0, writes the solved binary protobuf to *outputBuffer
/// and its length to *outputLength. The caller must free the output buffer
/// with destroyGraphBuffer().
///
/// On failure returns a non-zero error code. Call getErrorMessage() for a
/// human-readable description.
int solveGraphFromBuffer(void* inputBuffer, size_t inputLength,
                         void** outputBuffer, size_t* outputLength);

/// Frees a buffer previously returned by solveGraphFromBuffer().
void destroyGraphBuffer(void* graphBuffer);

/// Frees a JSON string previously returned by the C solveGraphFromJson().
void destroyGraphJson(char* graphJson);

/// Solves a circuit supplied as a JSON string.
///
/// On success returns 0 and writes the solved JSON to *outputJson. The caller
/// must free the string with destroyGraphJson().
///
/// On failure returns a non-zero error code.
int solveGraphFromJson(char* inputJson, char** outputJson);

/// Returns a human-readable description for the given error code.
const char* getErrorMessage(int errorNumber);

#endif  // CIRCUIT_SOLVER_FFI_H_
