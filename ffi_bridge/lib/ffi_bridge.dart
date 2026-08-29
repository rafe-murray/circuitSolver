import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:circuit_solver_proto/circuit_solver_proto.dart';

import 'src/circuit_solver_ffi.dart';

export 'src/circuit_solver_ffi.dart' show CircuitSolverException;

/// Solves the given circuit graph using the native circuitSolverLib.
///
/// The circuit is serialized to binary protobuf, passed to the native solver
/// on a dedicated helper isolate, and the result is deserialized back into a
/// [CircuitGraphMessage] before being returned.
///
/// Running the solver on a helper isolate ensures the calling isolate (e.g.
/// the Flutter UI isolate) is never blocked, even for circuits that take a
/// significant amount of time to solve.
///
/// Throws [CircuitSolverException] if:
/// - the input protobuf is malformed or the circuit topology is unsolvable
///   ([CircuitSolverException.code] == [CIRCUITSOLVER_ERROR_INVALID_INPUT]),
/// - the nonlinear solver could not converge on a solution
///   ([CircuitSolverException.code] == [CIRCUITSOLVER_ERROR_NO_SOLUTION]), or
/// - the result could not be serialized
///   ([CircuitSolverException.code] == [CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION]).
Future<CircuitGraphMessage> solveCircuit(CircuitGraphMessage input) async {
  // return await Isolate.run(() {
  //   final resultBytes = solveCircuitSync(input.writeToBuffer());
  //   return CircuitGraphMessage.fromBuffer(resultBytes);
  // });
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextRequestId++;
  final _SolveRequest request = _SolveRequest(requestId, input.writeToBuffer());
  final Completer<CircuitGraphMessage> completer =
      Completer<CircuitGraphMessage>();
  _pendingRequests[requestId] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
}

// ---------------------------------------------------------------------------
// Internal isolate plumbing
// ---------------------------------------------------------------------------

/// A request sent to the helper isolate.
class _SolveRequest {
  const _SolveRequest(this.id, this.inputBytes);

  final int id;
  final Uint8List inputBytes;
}

/// A successful response from the helper isolate.
class _SolveResponse {
  const _SolveResponse(this.id, this.outputBytes);

  final int id;
  final Uint8List outputBytes;
}

/// An error response from the helper isolate.
class _SolveError {
  const _SolveError(this.id, this.exception);

  final int id;
  final CircuitSolverException exception;
}

/// Monotonically increasing request counter.
int _nextRequestId = 0;

/// Map from in-flight request IDs to their completers.
final Map<int, Completer<CircuitGraphMessage>> _pendingRequests =
    <int, Completer<CircuitGraphMessage>>{};

/// The [SendPort] used to communicate with the long-lived helper isolate.
///
/// Lazily initialized on first use; the isolate lives for the lifetime of the
/// current isolate group.
final Future<SendPort> _helperIsolateSendPort = _startHelperIsolate();

Future<SendPort> _startHelperIsolate() async {
  final Completer<SendPort> completer = Completer<SendPort>();
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
        return;
      }
      if (data is _SolveResponse) {
        final Completer<CircuitGraphMessage> pendingCompleter = _pendingRequests
            .remove(data.id)!;
        pendingCompleter.complete(
          CircuitGraphMessage.fromBuffer(data.outputBytes),
        );
        return;
      }
      if (data is _SolveError) {
        final Completer<CircuitGraphMessage> pendingCompleter = _pendingRequests
            .remove(data.id)!;
        pendingCompleter.completeError(data.exception);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  await Isolate.spawn(_helperIsolateEntry, receivePort.sendPort);
  return completer.future;
}

/// Entry point for the helper isolate.
///
/// Listens for [_SolveRequest] messages, calls [solveCircuitSync] on the
/// native library, and sends back either a [_SolveResponse] or a
/// [_SolveError].
void _helperIsolateEntry(SendPort sendPort) {
  final ReceivePort helperReceivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is! _SolveRequest) {
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      }
      try {
        final Uint8List outputBytes = solveCircuitSync(data.inputBytes);
        sendPort.send(_SolveResponse(data.id, outputBytes));
      } on CircuitSolverException catch (e) {
        sendPort.send(_SolveError(data.id, e));
      }
    });

  sendPort.send(helperReceivePort.sendPort);
}
