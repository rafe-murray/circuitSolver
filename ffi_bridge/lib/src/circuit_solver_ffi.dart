import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'circuit_solver_bindings_generated.dart';

/// Exception thrown when the native circuitSolverLib returns an error.
///
/// The [code] corresponds to one of the `CIRCUITSOLVER_ERROR_*` constants
/// defined in the native API. Use [message] for a human-readable description
/// suitable for logging or display.
final class CircuitSolverException implements Exception {
  /// Creates a [CircuitSolverException] with the given native error [code] and
  /// [message].
  const CircuitSolverException(this.code, this.message);

  /// The native error code returned by the library.
  ///
  /// One of:
  /// - [CIRCUITSOLVER_ERROR_INVALID_INPUT] (1) — the input protobuf was
  ///   malformed or described an unsolvable topology.
  /// - [CIRCUITSOLVER_ERROR_NO_SOLUTION] (2) — the nonlinear solver could not
  ///   find a solution.
  /// - [CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION] (3) — the result could not
  ///   be serialized to protobuf.
  final int code;

  /// Human-readable description of the error from the native library.
  final String message;

  @override
  String toString() => 'CircuitSolverException($code): $message';
}

/// Synchronously solves [inputBytes] (binary protobuf encoding of a
/// [CircuitGraphMessage]) using the native circuitSolverLib.
///
/// Returns the solved circuit as a binary protobuf [Uint8List].
///
/// Throws [CircuitSolverException] if the native library returns a non-zero
/// error code.
///
/// This call blocks the current thread for the duration of the solve, which
/// may be significant for large or complex circuits. It must only be called
/// from a dedicated non-UI isolate — use [solveCircuit] from [ffi_bridge.dart]
/// for the isolate-backed public API.
Uint8List solveCircuitSync(Uint8List inputBytes) {
  final inputLength = inputBytes.length;
  final inputPtr = malloc<Uint8>(inputLength);

  try {
    // Copy Dart bytes into native memory.
    inputPtr.asTypedList(inputLength).setAll(0, inputBytes);

    return using((arena) {
      final outputPtrPtr = arena<Pointer<Void>>();
      final outputLengthPtr = arena<Size>();

      final errorCode = solveGraphFromBuffer(
        inputPtr.cast<Void>(),
        inputLength,
        outputPtrPtr,
        outputLengthPtr,
      );

      if (errorCode != 0) {
        final messagePtr = getErrorMessage(errorCode);
        final message = messagePtr.cast<Utf8>().toDartString();
        throw CircuitSolverException(errorCode, message);
      }

      final outputPtr = outputPtrPtr.value;
      final outputLength = outputLengthPtr.value;

      try {
        // Copy native output bytes into a Dart-owned Uint8List before freeing.
        final result = Uint8List.fromList(
          outputPtr.cast<Uint8>().asTypedList(outputLength),
        );
        return result;
      } finally {
        destroyGraphBuffer(outputPtr);
      }
    });
  } finally {
    malloc.free(inputPtr);
  }
}
