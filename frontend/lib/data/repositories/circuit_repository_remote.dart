import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:frontend/data/repositories/circuit_repository.dart';
import 'package:frontend/data/services/solver_service_remote.dart';

class CircuitRepositoryRemote implements CircuitRepository {
  CircuitRepositoryRemote({required SolverServiceRemote solverServiceRemote})
    : _solverServiceRemote = solverServiceRemote;
  final SolverServiceRemote _solverServiceRemote;

  @override
  Future<CircuitGraphMessage> solveCircuit(CircuitGraphMessage input) {
    return _solverServiceRemote.solve(input);
  }
}
