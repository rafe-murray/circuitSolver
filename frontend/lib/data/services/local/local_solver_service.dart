import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:ffi_bridge/ffi_bridge.dart';
import 'package:frontend/utils/result.dart';

class LocalSolverService {
  Future<Result<CircuitGraphMessage>> solve(CircuitGraphMessage input) async {
    try {
      final solvedCircuit = await solveCircuit(input);
      return Result.ok(solvedCircuit);
    } on CircuitSolverException catch (error) {
      return Result.error(error);
    }
  }
}
