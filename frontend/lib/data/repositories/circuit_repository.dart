import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/uuid_value.dart';

abstract class CircuitRepository {
  Future<Result<CircuitModel>> solveCircuit(CircuitModel circuit);
  Future<Result<void>> saveCircuit(CircuitModel circuit);
  Future<Result<CircuitModel>> getCircuit(UuidValue id);
  Future<Result<List<CircuitModel>>> getAllCircuits();
}
