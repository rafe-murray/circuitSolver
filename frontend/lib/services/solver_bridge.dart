import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// SolverService abstracts how the circuit solver is invoked.
///
/// Desktop native FFI will be implemented later. For web, this posts proto
/// bytes to a remote solver backend defined by the `SOLVER_BACKEND_URL`
/// environment variable or hardcoded endpoint.
class SolverService {
  SolverService({this.backendUrl});

  final String? backendUrl;

  /// Solve the circuit described by [protoBytes].
  ///
  /// On web, this performs an HTTP POST to the backend. On desktop/native
  /// targets this method is currently unimplemented and should be wired to
  /// the native library via dart:ffi.
  Future<List<int>> solve(List<int> protoBytes) async {
    if (kIsWeb) {
      final url =
          backendUrl ?? const String.fromEnvironment('SOLVER_BACKEND_URL');
      if (url.isEmpty) {
        throw StateError('SOLVER_BACKEND_URL not configured for web');
      }
      final resp = await http.post(
        Uri.parse(url),
        body: protoBytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );
      if (resp.statusCode != 200) {
        throw StateError(
          'Solver backend error: ${resp.statusCode} ${resp.reasonPhrase}',
        );
      }
      return resp.bodyBytes;
    }

    // Desktop/native: Implement dart:ffi bridge to native solver library.
    throw UnimplementedError('Native solver not implemented yet.');
  }
}
