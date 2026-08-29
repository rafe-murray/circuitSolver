import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/utils/exceptions.dart';
import 'package:frontend/utils/result.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'local_storage_service.g.dart';

class LocalStorageService {
  LocalStorageService({required CircuitSolverDatabase db}) : _db = db;
  final CircuitSolverDatabase _db;
  Future<Result<CircuitLocalStorageModel>> getCircuit(UuidValue id) async {
    try {
      final circuitRecord =
          await (_db.circuits.select()
                ..where((circuit) => circuit.id.equals(id.toBytes())))
              .getSingleOrNull();
      if (circuitRecord == null) {
        return Result.error(NotFoundException('Id $id not found'));
      }
      return Result.ok(_localStorageModelFromDatabaseModel(circuitRecord));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<List<CircuitLocalStorageModel>>> getCircuits({
    int limit = 50,
  }) async {
    try {
      final circuitRecords =
          await (_db.circuits.select()
                ..limit(limit)
                ..orderBy([
                  (circuit) => OrderingTerm(
                    expression: circuit.modified,
                    mode: OrderingMode.desc,
                  ),
                ]))
              .get();
      print(
        "Current circuit ids from db id: ${circuitRecords.map((record) => UuidValue.fromByteList(record.id))}",
      );
      print(
        "Current circuit ids from circuit.id: ${circuitRecords.map((record) => CircuitModelMapper.fromJson(record.circuit).id)}",
      );
      final circuits = circuitRecords
          .map(_localStorageModelFromDatabaseModel)
          .toList();
      return Result.ok(circuits);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> putCircuit(CircuitLocalStorageModel circuit) async {
    try {
      await _db.circuits.insert().insert(
        circuit._toDatabaseModel(),
        mode: InsertMode.replace,
      );
      return Result<void>.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> deleteCircuit(UuidValue id) async {
    try {
      final countDeleted = await _db.circuits.deleteWhere(
        (circuit) => circuit.id.equals(id.toBytes()),
      );
      if (countDeleted == 0) {
        return Result.error(NotFoundException("No Circuit found with id $id"));
      } else if (countDeleted > 1) {
        return Result.error(
          Exception("More than one circuit deleted with the same id: $id"),
        );
      }
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}

extension on CircuitLocalStorageModel {
  Insertable<_Circuit> _toDatabaseModel() {
    return _CircuitsCompanion(
      id: Value(id.toBytes()),
      name: Value(name),
      created: Value(created),
      modified: Value(modified),
      circuit: Value(circuit.toJson()),
    );
  }
}

CircuitLocalStorageModel _localStorageModelFromDatabaseModel(
  _Circuit circuitRecord,
) {
  // final List<dynamic> jsonWires = jsonDecode(circuitRecord.wires);
  // final List<dynamic> jsonComponents = jsonDecode(circuitRecord.components);
  return CircuitLocalStorageModel(
    id: UuidValue.fromByteList(circuitRecord.id),
    name: circuitRecord.name,
    created: circuitRecord.created,
    modified: circuitRecord.modified,
    circuit: CircuitModelMapper.fromJson(circuitRecord.circuit),
  );
}

class _Circuits extends Table {
  BlobColumn get id => blob()();
  TextColumn get name => text()();
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modified => dateTime().withDefault(currentDateAndTime)();
  TextColumn get circuit => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [_Circuits])
class CircuitSolverDatabase extends _$CircuitSolverDatabase {
  CircuitSolverDatabase() : super(_db);
  CircuitSolverDatabase.memory() : super(NativeDatabase.memory());
  @override
  int get schemaVersion => 1;

  static LazyDatabase get _db {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(path.join(dir.path, 'circuitsolver.db'));
      return NativeDatabase(dbFile);
    });
  }
}
