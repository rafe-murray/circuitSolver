import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:http/http.dart' as http;

/// SolverService abstracts how the circuit solver is invoked.
///
/// Desktop native FFI will be implemented later. For web, this posts proto
/// bytes to a remote solver backend defined by the `SOLVER_BACKEND_URL`
/// environment variable or hardcoded endpoint.
class SolverServiceRemote {
  SolverServiceRemote({this.backendUrl});

  final String? backendUrl;

  /// Solve the circuit described by [protoBytes].
  ///
  /// This performs an HTTP POST to the backend.
  Future<CircuitGraphMessage> solve(CircuitGraphMessage input) async {
    final url =
        backendUrl ?? const String.fromEnvironment('SOLVER_BACKEND_URL');
    if (url.isEmpty) {
      throw StateError('SOLVER_BACKEND_URL not configured for web');
    }
    final res = await http.post(
      Uri.parse(url),
      body: input.writeToBuffer(),
      headers: {'Content-Type': 'application/octet-stream'},
    );
    if (res.statusCode != 200) {
      throw StateError(
        'Solver backend error: ${res.statusCode} ${res.reasonPhrase}',
      );
    }
    return CircuitGraphMessage.fromBuffer(res.bodyBytes);
  }
}
