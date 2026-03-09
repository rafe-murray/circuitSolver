// ignore: unnecessary_import — Uint8List used in public API signatures.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'storage.g.dart';

class Circuits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BlobColumn get protoBytes => blob()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Circuits])
class AppDatabase extends _$AppDatabase {
  /// Opens a persistent on-disk database.
  AppDatabase() : super(_openConnection());

  /// Opens a transient in-memory database (for testing).
  AppDatabase._memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  Future<int> insertCircuit(String name, Uint8List proto) => into(
    circuits,
  ).insert(CircuitsCompanion.insert(name: name, protoBytes: proto));

  Future<int> upsertCircuit(int id, String name, Uint8List proto) =>
      (update(circuits)..where((t) => t.id.equals(id))).write(
        CircuitsCompanion(
          name: Value(name),
          protoBytes: Value(proto),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Future<void> deleteCircuit(int id) =>
      (delete(circuits)..where((t) => t.id.equals(id))).go();

  Future<List<Circuit>> listCircuits() => (select(
    circuits,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<Circuit?> getCircuitById(int id) =>
      (select(circuits)..where((t) => t.id.equals(id))).getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Web does not support file-backed SQLite; use in-memory.
      return NativeDatabase.memory();
    }
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'circuit_solver.db'));
    return NativeDatabase(dbFile);
  });
}

/// Thin repository facade for storage operations.
class StorageService {
  StorageService._(this._db);

  final AppDatabase _db;

  /// Creates a [StorageService] backed by a persistent on-disk SQLite database.
  static Future<StorageService> create() async {
    final db = AppDatabase();
    return StorageService._(db);
  }

  /// Creates a [StorageService] backed by a transient in-memory database.
  ///
  /// Use this in tests to avoid touching the file system.
  static Future<StorageService> createInMemory() async {
    final db = AppDatabase._memory();
    return StorageService._(db);
  }

  Future<int> saveCircuit(String name, Uint8List proto) =>
      _db.insertCircuit(name, proto);

  Future<void> updateCircuit(int id, String name, Uint8List proto) =>
      _db.upsertCircuit(id, name, proto);

  Future<void> deleteCircuit(int id) => _db.deleteCircuit(id);

  Future<List<Circuit>> list() => _db.listCircuits();

  Future<Circuit?> load(int id) => _db.getCircuitById(id);
}
