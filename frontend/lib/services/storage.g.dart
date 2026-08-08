// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// ignore_for_file: type=lint
class $CircuitsTable extends Circuits with TableInfo<$CircuitsTable, Circuit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CircuitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _protoBytesMeta = const VerificationMeta(
    'protoBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> protoBytes = GeneratedColumn<Uint8List>(
    'proto_bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    protoBytes,
    createdAt,
    modifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circuits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Circuit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('proto_bytes')) {
      context.handle(
        _protoBytesMeta,
        protoBytes.isAcceptableOrUnknown(data['proto_bytes']!, _protoBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_protoBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Circuit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Circuit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      protoBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}proto_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      ),
    );
  }

  @override
  $CircuitsTable createAlias(String alias) {
    return $CircuitsTable(attachedDatabase, alias);
  }
}

class Circuit extends DataClass implements Insertable<Circuit> {
  final int id;
  final String name;
  final Uint8List protoBytes;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  const Circuit({
    required this.id,
    required this.name,
    required this.protoBytes,
    required this.createdAt,
    this.modifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['proto_bytes'] = Variable<Uint8List>(protoBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || modifiedAt != null) {
      map['modified_at'] = Variable<DateTime>(modifiedAt);
    }
    return map;
  }

  CircuitsCompanion toCompanion(bool nullToAbsent) {
    return CircuitsCompanion(
      id: Value(id),
      name: Value(name),
      protoBytes: Value(protoBytes),
      createdAt: Value(createdAt),
      modifiedAt: modifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedAt),
    );
  }

  factory Circuit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Circuit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      protoBytes: serializer.fromJson<Uint8List>(json['protoBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime?>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'protoBytes': serializer.toJson<Uint8List>(protoBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime?>(modifiedAt),
    };
  }

  Circuit copyWith({
    int? id,
    String? name,
    Uint8List? protoBytes,
    DateTime? createdAt,
    Value<DateTime?> modifiedAt = const Value.absent(),
  }) => Circuit(
    id: id ?? this.id,
    name: name ?? this.name,
    protoBytes: protoBytes ?? this.protoBytes,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt.present ? modifiedAt.value : this.modifiedAt,
  );
  Circuit copyWithCompanion(CircuitsCompanion data) {
    return Circuit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      protoBytes: data.protoBytes.present
          ? data.protoBytes.value
          : this.protoBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Circuit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('protoBytes: $protoBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    $driftBlobEquality.hash(protoBytes),
    createdAt,
    modifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Circuit &&
          other.id == this.id &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.protoBytes, this.protoBytes) &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class CircuitsCompanion extends UpdateCompanion<Circuit> {
  final Value<int> id;
  final Value<String> name;
  final Value<Uint8List> protoBytes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> modifiedAt;
  const CircuitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.protoBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  });
  CircuitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Uint8List protoBytes,
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  }) : name = Value(name),
       protoBytes = Value(protoBytes);
  static Insertable<Circuit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<Uint8List>? protoBytes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (protoBytes != null) 'proto_bytes': protoBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
    });
  }

  CircuitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<Uint8List>? protoBytes,
    Value<DateTime>? createdAt,
    Value<DateTime?>? modifiedAt,
  }) {
    return CircuitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      protoBytes: protoBytes ?? this.protoBytes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (protoBytes.present) {
      map['proto_bytes'] = Variable<Uint8List>(protoBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CircuitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('protoBytes: $protoBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CircuitsTable circuits = $CircuitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [circuits];
}

typedef $$CircuitsTableCreateCompanionBuilder =
    CircuitsCompanion Function({
      Value<int> id,
      required String name,
      required Uint8List protoBytes,
      Value<DateTime> createdAt,
      Value<DateTime?> modifiedAt,
    });
typedef $$CircuitsTableUpdateCompanionBuilder =
    CircuitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<Uint8List> protoBytes,
      Value<DateTime> createdAt,
      Value<DateTime?> modifiedAt,
    });

class $$CircuitsTableFilterComposer
    extends Composer<_$AppDatabase, $CircuitsTable> {
  $$CircuitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get protoBytes => $composableBuilder(
    column: $table.protoBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CircuitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CircuitsTable> {
  $$CircuitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get protoBytes => $composableBuilder(
    column: $table.protoBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CircuitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CircuitsTable> {
  $$CircuitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get protoBytes => $composableBuilder(
    column: $table.protoBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );
}

class $$CircuitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CircuitsTable,
          Circuit,
          $$CircuitsTableFilterComposer,
          $$CircuitsTableOrderingComposer,
          $$CircuitsTableAnnotationComposer,
          $$CircuitsTableCreateCompanionBuilder,
          $$CircuitsTableUpdateCompanionBuilder,
          (Circuit, BaseReferences<_$AppDatabase, $CircuitsTable, Circuit>),
          Circuit,
          PrefetchHooks Function()
        > {
  $$CircuitsTableTableManager(_$AppDatabase db, $CircuitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CircuitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CircuitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CircuitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Uint8List> protoBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
              }) => CircuitsCompanion(
                id: id,
                name: name,
                protoBytes: protoBytes,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required Uint8List protoBytes,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
              }) => CircuitsCompanion.insert(
                id: id,
                name: name,
                protoBytes: protoBytes,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CircuitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CircuitsTable,
      Circuit,
      $$CircuitsTableFilterComposer,
      $$CircuitsTableOrderingComposer,
      $$CircuitsTableAnnotationComposer,
      $$CircuitsTableCreateCompanionBuilder,
      $$CircuitsTableUpdateCompanionBuilder,
      (Circuit, BaseReferences<_$AppDatabase, $CircuitsTable, Circuit>),
      Circuit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CircuitsTableTableManager get circuits =>
      $$CircuitsTableTableManager(_db, _db.circuits);
}
