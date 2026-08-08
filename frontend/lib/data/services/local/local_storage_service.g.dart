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
  static const VerificationMeta _wiresMeta = const VerificationMeta('wires');
  @override
  late final GeneratedColumn<String> wires = GeneratedColumn<String>(
    'wires',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _componentsMeta = const VerificationMeta(
    'components',
  );
  @override
  late final GeneratedColumn<String> components = GeneratedColumn<String>(
    'components',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    wires,
    components,
    created,
    modified,
  ];
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
    if (data.containsKey('wires')) {
      context.handle(
        _wiresMeta,
        wires.isAcceptableOrUnknown(data['wires']!, _wiresMeta),
      );
    } else if (isInserting) {
      context.missing(_wiresMeta);
    }
    if (data.containsKey('components')) {
      context.handle(
        _componentsMeta,
        components.isAcceptableOrUnknown(data['components']!, _componentsMeta),
      );
    } else if (isInserting) {
      context.missing(_componentsMeta);
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
      wires: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wires'],
      )!,
      components: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}components'],
      )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified'],
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
  final String wires;
  final String components;
  final DateTime created;
  final DateTime modified;
  const _Circuit({
    required this.id,
    required this.name,
    required this.wires,
    required this.components,
    required this.created,
    required this.modified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['name'] = Variable<String>(name);
    map['wires'] = Variable<String>(wires);
    map['components'] = Variable<String>(components);
    map['created'] = Variable<DateTime>(created);
    map['modified'] = Variable<DateTime>(modified);
    return map;
  }

  _CircuitsCompanion toCompanion(bool nullToAbsent) {
    return _CircuitsCompanion(
      id: Value(id),
      name: Value(name),
      wires: Value(wires),
      components: Value(components),
      created: Value(created),
      modified: Value(modified),
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
      wires: serializer.fromJson<String>(json['wires']),
      components: serializer.fromJson<String>(json['components']),
      created: serializer.fromJson<DateTime>(json['created']),
      modified: serializer.fromJson<DateTime>(json['modified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'name': serializer.toJson<String>(name),
      'wires': serializer.toJson<String>(wires),
      'components': serializer.toJson<String>(components),
      'created': serializer.toJson<DateTime>(created),
      'modified': serializer.toJson<DateTime>(modified),
    };
  }

  _Circuit copyWith({
    Uint8List? id,
    String? name,
    String? wires,
    String? components,
    DateTime? created,
    DateTime? modified,
  }) => _Circuit(
    id: id ?? this.id,
    name: name ?? this.name,
    wires: wires ?? this.wires,
    components: components ?? this.components,
    created: created ?? this.created,
    modified: modified ?? this.modified,
  );
  _Circuit copyWithCompanion(_CircuitsCompanion data) {
    return _Circuit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      wires: data.wires.present ? data.wires.value : this.wires,
      components: data.components.present
          ? data.components.value
          : this.components,
      created: data.created.present ? data.created.value : this.created,
      modified: data.modified.present ? data.modified.value : this.modified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('_Circuit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wires: $wires, ')
          ..write('components: $components, ')
          ..write('created: $created, ')
          ..write('modified: $modified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    $driftBlobEquality.hash(id),
    name,
    wires,
    components,
    created,
    modified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _Circuit &&
          $driftBlobEquality.equals(other.id, this.id) &&
          other.name == this.name &&
          other.wires == this.wires &&
          other.components == this.components &&
          other.created == this.created &&
          other.modified == this.modified);
}

class _CircuitsCompanion extends UpdateCompanion<_Circuit> {
  final Value<Uint8List> id;
  final Value<String> name;
  final Value<String> wires;
  final Value<String> components;
  final Value<DateTime> created;
  final Value<DateTime> modified;
  final Value<int> rowid;
  const _CircuitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.wires = const Value.absent(),
    this.components = const Value.absent(),
    this.created = const Value.absent(),
    this.modified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  _CircuitsCompanion.insert({
    required Uint8List id,
    required String name,
    required String wires,
    required String components,
    this.created = const Value.absent(),
    this.modified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       wires = Value(wires),
       components = Value(components);
  static Insertable<_Circuit> custom({
    Expression<Uint8List>? id,
    Expression<String>? name,
    Expression<String>? wires,
    Expression<String>? components,
    Expression<DateTime>? created,
    Expression<DateTime>? modified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (wires != null) 'wires': wires,
      if (components != null) 'components': components,
      if (created != null) 'created': created,
      if (modified != null) 'modified': modified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  _CircuitsCompanion copyWith({
    Value<Uint8List>? id,
    Value<String>? name,
    Value<String>? wires,
    Value<String>? components,
    Value<DateTime>? created,
    Value<DateTime>? modified,
    Value<int>? rowid,
  }) {
    return _CircuitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      wires: wires ?? this.wires,
      components: components ?? this.components,
      created: created ?? this.created,
      modified: modified ?? this.modified,
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
    if (wires.present) {
      map['wires'] = Variable<String>(wires.value);
    }
    if (components.present) {
      map['components'] = Variable<String>(components.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (modified.present) {
      map['modified'] = Variable<DateTime>(modified.value);
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
          ..write('wires: $wires, ')
          ..write('components: $components, ')
          ..write('created: $created, ')
          ..write('modified: $modified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$_CircuitSolverDatabase extends GeneratedDatabase {
  _$_CircuitSolverDatabase(QueryExecutor e) : super(e);
  $_CircuitSolverDatabaseManager get managers =>
      $_CircuitSolverDatabaseManager(this);
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
      required String wires,
      required String components,
      Value<DateTime> created,
      Value<DateTime> modified,
      Value<int> rowid,
    });
typedef $$_CircuitsTableUpdateCompanionBuilder =
    _CircuitsCompanion Function({
      Value<Uint8List> id,
      Value<String> name,
      Value<String> wires,
      Value<String> components,
      Value<DateTime> created,
      Value<DateTime> modified,
      Value<int> rowid,
    });

class $$_CircuitsTableFilterComposer
    extends Composer<_$_CircuitSolverDatabase, $_CircuitsTable> {
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

  ColumnFilters<String> get wires => $composableBuilder(
    column: $table.wires,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get components => $composableBuilder(
    column: $table.components,
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
}

class $$_CircuitsTableOrderingComposer
    extends Composer<_$_CircuitSolverDatabase, $_CircuitsTable> {
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

  ColumnOrderings<String> get wires => $composableBuilder(
    column: $table.wires,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get components => $composableBuilder(
    column: $table.components,
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
}

class $$_CircuitsTableAnnotationComposer
    extends Composer<_$_CircuitSolverDatabase, $_CircuitsTable> {
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

  GeneratedColumn<String> get wires =>
      $composableBuilder(column: $table.wires, builder: (column) => column);

  GeneratedColumn<String> get components => $composableBuilder(
    column: $table.components,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);
}

class $$_CircuitsTableTableManager
    extends
        RootTableManager<
          _$_CircuitSolverDatabase,
          $_CircuitsTable,
          _Circuit,
          $$_CircuitsTableFilterComposer,
          $$_CircuitsTableOrderingComposer,
          $$_CircuitsTableAnnotationComposer,
          $$_CircuitsTableCreateCompanionBuilder,
          $$_CircuitsTableUpdateCompanionBuilder,
          (
            _Circuit,
            BaseReferences<_$_CircuitSolverDatabase, $_CircuitsTable, _Circuit>,
          ),
          _Circuit,
          PrefetchHooks Function()
        > {
  $$_CircuitsTableTableManager(
    _$_CircuitSolverDatabase db,
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
                Value<String> wires = const Value.absent(),
                Value<String> components = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> modified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => _CircuitsCompanion(
                id: id,
                name: name,
                wires: wires,
                components: components,
                created: created,
                modified: modified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uint8List id,
                required String name,
                required String wires,
                required String components,
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> modified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => _CircuitsCompanion.insert(
                id: id,
                name: name,
                wires: wires,
                components: components,
                created: created,
                modified: modified,
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
      _$_CircuitSolverDatabase,
      $_CircuitsTable,
      _Circuit,
      $$_CircuitsTableFilterComposer,
      $$_CircuitsTableOrderingComposer,
      $$_CircuitsTableAnnotationComposer,
      $$_CircuitsTableCreateCompanionBuilder,
      $$_CircuitsTableUpdateCompanionBuilder,
      (
        _Circuit,
        BaseReferences<_$_CircuitSolverDatabase, $_CircuitsTable, _Circuit>,
      ),
      _Circuit,
      PrefetchHooks Function()
    >;

class $_CircuitSolverDatabaseManager {
  final _$_CircuitSolverDatabase _db;
  $_CircuitSolverDatabaseManager(this._db);
  $$_CircuitsTableTableManager get circuits =>
      $$_CircuitsTableTableManager(_db, _db.circuits);
}
