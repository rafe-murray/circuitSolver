// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(uuid)
final uuidProvider = UuidProvider._();

final class UuidProvider extends $FunctionalProvider<Uuid, Uuid, Uuid>
    with $Provider<Uuid> {
  UuidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uuidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uuidHash();

  @$internal
  @override
  $ProviderElement<Uuid> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uuid create(Ref ref) {
    return uuid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uuid value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uuid>(value),
    );
  }
}

String _$uuidHash() => r'705956b657aa32243556b044bffa026ae299734c';

@ProviderFor(circuitRepository)
final circuitRepositoryProvider = CircuitRepositoryProvider._();

final class CircuitRepositoryProvider
    extends
        $FunctionalProvider<
          CircuitRepository,
          CircuitRepository,
          CircuitRepository
        >
    with $Provider<CircuitRepository> {
  CircuitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'circuitRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$circuitRepositoryHash();

  @$internal
  @override
  $ProviderElement<CircuitRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CircuitRepository create(Ref ref) {
    return circuitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CircuitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CircuitRepository>(value),
    );
  }
}

String _$circuitRepositoryHash() => r'3257c1bf935d9abe18853c0608997785fa8bfc7a';

@ProviderFor(localSolverService)
final localSolverServiceProvider = LocalSolverServiceProvider._();

final class LocalSolverServiceProvider
    extends
        $FunctionalProvider<
          LocalSolverService,
          LocalSolverService,
          LocalSolverService
        >
    with $Provider<LocalSolverService> {
  LocalSolverServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localSolverServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localSolverServiceHash();

  @$internal
  @override
  $ProviderElement<LocalSolverService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalSolverService create(Ref ref) {
    return localSolverService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalSolverService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalSolverService>(value),
    );
  }
}

String _$localSolverServiceHash() =>
    r'686fd3348c087fde1addf45f97f4d412720b0968';

@ProviderFor(localStorageService)
final localStorageServiceProvider = LocalStorageServiceProvider._();

final class LocalStorageServiceProvider
    extends
        $FunctionalProvider<
          LocalStorageService,
          LocalStorageService,
          LocalStorageService
        >
    with $Provider<LocalStorageService> {
  LocalStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localStorageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localStorageServiceHash();

  @$internal
  @override
  $ProviderElement<LocalStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalStorageService create(Ref ref) {
    return localStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalStorageService>(value),
    );
  }
}

String _$localStorageServiceHash() =>
    r'f930bdc830566049b82dfac6430890a2457ac6e2';

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

final class DatabaseProvider
    extends
        $FunctionalProvider<
          CircuitSolverDatabase,
          CircuitSolverDatabase,
          CircuitSolverDatabase
        >
    with $Provider<CircuitSolverDatabase> {
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<CircuitSolverDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CircuitSolverDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CircuitSolverDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CircuitSolverDatabase>(value),
    );
  }
}

String _$databaseHash() => r'120e88412df3942213daa7c29f08bdde8b327727';
