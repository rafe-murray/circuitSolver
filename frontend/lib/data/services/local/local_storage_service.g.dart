// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_storage_service.dart';

// ignore_for_file: type=lint
class $_CircuitsTable extends _Circuits
    with TableInfo<$_CircuitsTable, _Circuit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $_CircuitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<Uint8List> id = GeneratedColumn<Uint8List>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<DateTime> modified = GeneratedColumn<DateTime>(
    'modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _circuitMeta = const VerificationMeta(
    'circuit',
  );
  @override
  late final GeneratedColumn<String> circuit = GeneratedColumn<String>(
    'circuit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, created, modified, circuit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circuits';
  @override
  VerificationContext validateIntegrity(
    Insertable<_Circuit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('circuit')) {
      context.handle(
        _circuitMeta,
        circuit.isAcceptableOrUnknown(data['circuit']!, _circuitMeta),
      );
    } else if (isInserting) {
      context.missing(_circuitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  _Circuit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return _Circuit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified'],
      )!,
      circuit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circuit'],
      )!,
    );
  }

  @override
  $_CircuitsTable createAlias(String alias) {
    return $_CircuitsTable(attachedDatabase, alias);
  }
}

class _Circuit extends DataClass implements Insertable<_Circuit> {
  final Uint8List id;
  final String name;
  final DateTime created;
  final DateTime modified;
  final String circuit;
  const _Circuit({
    required this.id,
    required this.name,
    required this.created,
    required this.modified,
    required this.circuit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['name'] = Variable<String>(name);
    map['created'] = Variable<DateTime>(created);
    map['modified'] = Variable<DateTime>(modified);
    map['circuit'] = Variable<String>(circuit);
    return map;
  }

  _CircuitsCompanion toCompanion(bool nullToAbsent) {
    return _CircuitsCompanion(
      id: Value(id),
      name: Value(name),
      created: Value(created),
      modified: Value(modified),
      circuit: Value(circuit),
    );
  }

  factory _Circuit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return _Circuit(
      id: serializer.fromJson<Uint8List>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      created: serializer.fromJson<DateTime>(json['created']),
      modified: serializer.fromJson<DateTime>(json['modified']),
      circuit: serializer.fromJson<String>(json['circuit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'name': serializer.toJson<String>(name),
      'created': serializer.toJson<DateTime>(created),
      'modified': serializer.toJson<DateTime>(modified),
      'circuit': serializer.toJson<String>(circuit),
    };
  }

  _Circuit copyWith({
    Uint8List? id,
    String? name,
    DateTime? created,
    DateTime? modified,
    String? circuit,
  }) => _Circuit(
    id: id ?? this.id,
    name: name ?? this.name,
    created: created ?? this.created,
    modified: modified ?? this.modified,
    circuit: circuit ?? this.circuit,
  );
  _Circuit copyWithCompanion(_CircuitsCompanion data) {
    return _Circuit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      created: data.created.present ? data.created.value : this.created,
      modified: data.modified.present ? data.modified.value : this.modified,
      circuit: data.circuit.present ? data.circuit.value : this.circuit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('_Circuit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created, ')
          ..write('modified: $modified, ')
          ..write('circuit: $circuit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    $driftBlobEquality.hash(id),
    name,
    created,
    modified,
    circuit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _Circuit &&
          $driftBlobEquality.equals(other.id, this.id) &&
          other.name == this.name &&
          other.created == this.created &&
          other.modified == this.modified &&
          other.circuit == this.circuit);
}

class _CircuitsCompanion extends UpdateCompanion<_Circuit> {
  final Value<Uint8List> id;
  final Value<String> name;
  final Value<DateTime> created;
  final Value<DateTime> modified;
  final Value<String> circuit;
  final Value<int> rowid;
  const _CircuitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.created = const Value.absent(),
    this.modified = const Value.absent(),
    this.circuit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  _CircuitsCompanion.insert({
    required Uint8List id,
    required String name,
    this.created = const Value.absent(),
    this.modified = const Value.absent(),
    required String circuit,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       circuit = Value(circuit);
  static Insertable<_Circuit> custom({
    Expression<Uint8List>? id,
    Expression<String>? name,
    Expression<DateTime>? created,
    Expression<DateTime>? modified,
    Expression<String>? circuit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (created != null) 'created': created,
      if (modified != null) 'modified': modified,
      if (circuit != null) 'circuit': circuit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  _CircuitsCompanion copyWith({
    Value<Uint8List>? id,
    Value<String>? name,
    Value<DateTime>? created,
    Value<DateTime>? modified,
    Value<String>? circuit,
    Value<int>? rowid,
  }) {
    return _CircuitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      circuit: circuit ?? this.circuit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (modified.present) {
      map['modified'] = Variable<DateTime>(modified.value);
    }
    if (circuit.present) {
      map['circuit'] = Variable<String>(circuit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('_CircuitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created, ')
          ..write('modified: $modified, ')
          ..write('circuit: $circuit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CircuitSolverDatabase extends GeneratedDatabase {
  _$CircuitSolverDatabase(QueryExecutor e) : super(e);
  $CircuitSolverDatabaseManager get managers =>
      $CircuitSolverDatabaseManager(this);
  late final $_CircuitsTable circuits = $_CircuitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [circuits];
}

typedef $$_CircuitsTableCreateCompanionBuilder =
    _CircuitsCompanion Function({
      required Uint8List id,
      required String name,
      Value<DateTime> created,
      Value<DateTime> modified,
      required String circuit,
      Value<int> rowid,
    });
typedef $$_CircuitsTableUpdateCompanionBuilder =
    _CircuitsCompanion Function({
      Value<Uint8List> id,
      Value<String> name,
      Value<DateTime> created,
      Value<DateTime> modified,
      Value<String> circuit,
      Value<int> rowid,
    });

class $$_CircuitsTableFilterComposer
    extends Composer<_$CircuitSolverDatabase, $_CircuitsTable> {
  $$_CircuitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circuit => $composableBuilder(
    column: $table.circuit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$_CircuitsTableOrderingComposer
    extends Composer<_$CircuitSolverDatabase, $_CircuitsTable> {
  $$_CircuitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circuit => $composableBuilder(
    column: $table.circuit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$_CircuitsTableAnnotationComposer
    extends Composer<_$CircuitSolverDatabase, $_CircuitsTable> {
  $$_CircuitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<String> get circuit =>
      $composableBuilder(column: $table.circuit, builder: (column) => column);
}

class $$_CircuitsTableTableManager
    extends
        RootTableManager<
          _$CircuitSolverDatabase,
          $_CircuitsTable,
          _Circuit,
          $$_CircuitsTableFilterComposer,
          $$_CircuitsTableOrderingComposer,
          $$_CircuitsTableAnnotationComposer,
          $$_CircuitsTableCreateCompanionBuilder,
          $$_CircuitsTableUpdateCompanionBuilder,
          (
            _Circuit,
            BaseReferences<_$CircuitSolverDatabase, $_CircuitsTable, _Circuit>,
          ),
          _Circuit,
          PrefetchHooks Function()
        > {
  $$_CircuitsTableTableManager(
    _$CircuitSolverDatabase db,
    $_CircuitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$_CircuitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$_CircuitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$_CircuitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Uint8List> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> modified = const Value.absent(),
                Value<String> circuit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => _CircuitsCompanion(
                id: id,
                name: name,
                created: created,
                modified: modified,
                circuit: circuit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uint8List id,
                required String name,
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> modified = const Value.absent(),
                required String circuit,
                Value<int> rowid = const Value.absent(),
              }) => _CircuitsCompanion.insert(
                id: id,
                name: name,
                created: created,
                modified: modified,
                circuit: circuit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$_CircuitsTableProcessedTableManager =
    ProcessedTableManager<
      _$CircuitSolverDatabase,
      $_CircuitsTable,
      _Circuit,
      $$_CircuitsTableFilterComposer,
      $$_CircuitsTableOrderingComposer,
      $$_CircuitsTableAnnotationComposer,
      $$_CircuitsTableCreateCompanionBuilder,
      $$_CircuitsTableUpdateCompanionBuilder,
      (
        _Circuit,
        BaseReferences<_$CircuitSolverDatabase, $_CircuitsTable, _Circuit>,
      ),
      _Circuit,
      PrefetchHooks Function()
    >;

class $CircuitSolverDatabaseManager {
  final _$CircuitSolverDatabase _db;
  $CircuitSolverDatabaseManager(this._db);
  $$_CircuitsTableTableManager get circuits =>
      $$_CircuitsTableTableManager(_db, _db.circuits);
}
