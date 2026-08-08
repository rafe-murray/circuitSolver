import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/utils/result.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'local_storage_service.g.dart';

class LocalStorageService {
  Future<Result<CircuitLocalStorageModel>> getCircuit(UuidValue id) async {
    try {
      final circuitRecord =
          await (_db.circuits.select()
                ..where((circuit) => circuit.id.equals(id.toBytes())))
              .getSingle();
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

  final _CircuitSolverDatabase _db = _CircuitSolverDatabase();
}

extension on CircuitLocalStorageModel {
  Insertable<_Circuit> _toDatabaseModel() {
    return _CircuitsCompanion(
      id: Value(id.toBytes()),
      name: Value(name),
      wires: Value(
        '[${wires.map((wire) => jsonEncode(wire.toJson())).join(',')}]',
      ),
      components: Value(
        '[${components.map((component) => jsonEncode(component.toJson())).join(',')}]',
      ),
      created: Value(created),
      modified: Value(modified),
    );
  }
}

CircuitLocalStorageModel _localStorageModelFromDatabaseModel(
  _Circuit circuitRecord,
) {
  final List<Map<String, dynamic>> jsonWires = jsonDecode(circuitRecord.wires);
  final List<Map<String, dynamic>> jsonComponents = jsonDecode(
    circuitRecord.components,
  );
  return CircuitLocalStorageModel(
    id: UuidValue.fromByteList(circuitRecord.id),
    name: circuitRecord.name,
    created: circuitRecord.created,
    modified: circuitRecord.modified,
    wires: jsonWires.map(WireModel.fromJson).toList(),
    components: jsonComponents.map(ComponentModel.fromJson).toList(),
  );
}

class _Circuits extends Table {
  BlobColumn get id => blob()();
  TextColumn get name => text()();
  TextColumn get wires => text()();
  TextColumn get components => text()();
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modified => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [_Circuits])
class _CircuitSolverDatabase extends _$_CircuitSolverDatabase {
  _CircuitSolverDatabase() : super(_db);

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
