// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nextFrom)
final nextFromProvider = NextFromProvider._();

final class NextFromProvider extends $FunctionalProvider<Offset, Offset, Offset>
    with $Provider<Offset> {
  NextFromProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextFromProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextFromHash();

  @$internal
  @override
  $ProviderElement<Offset> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Offset create(Ref ref) {
    return nextFrom(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Offset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Offset>(value),
    );
  }
}

String _$nextFromHash() => r'4fc00d018aa973b88a0fc99434937e4714f01085';

@ProviderFor(nextTo)
final nextToProvider = NextToProvider._();

final class NextToProvider extends $FunctionalProvider<Offset, Offset, Offset>
    with $Provider<Offset> {
  NextToProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextToProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextToHash();

  @$internal
  @override
  $ProviderElement<Offset> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Offset create(Ref ref) {
    return nextTo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Offset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Offset>(value),
    );
  }
}

String _$nextToHash() => r'1059316ea2a7f473a5143e5b5acaa4d9e31dd595';

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

@ProviderFor(CircuitViewModel)
final circuitViewModelProvider = CircuitViewModelFamily._();

final class CircuitViewModelProvider
    extends $AsyncNotifierProvider<CircuitViewModel, CircuitModel> {
  CircuitViewModelProvider._({
    required CircuitViewModelFamily super.from,
    required UuidValue super.argument,
  }) : super(
         retry: null,
         name: r'circuitViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$circuitViewModelHash();

  @override
  String toString() {
    return r'circuitViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CircuitViewModel create() => CircuitViewModel();

  @override
  bool operator ==(Object other) {
    return other is CircuitViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$circuitViewModelHash() => r'3fd981a4c696be0ffa2ab0b952a3cf112238cf15';

final class CircuitViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CircuitViewModel,
          AsyncValue<CircuitModel>,
          CircuitModel,
          FutureOr<CircuitModel>,
          UuidValue
        > {
  CircuitViewModelFamily._()
    : super(
        retry: null,
        name: r'circuitViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CircuitViewModelProvider call({required UuidValue circuitId}) =>
      CircuitViewModelProvider._(argument: circuitId, from: this);

  @override
  String toString() => r'circuitViewModelProvider';
}

abstract class _$CircuitViewModel extends $AsyncNotifier<CircuitModel> {
  late final _$args = ref.$arg as UuidValue;
  UuidValue get circuitId => _$args;

  FutureOr<CircuitModel> build({required UuidValue circuitId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CircuitModel>, CircuitModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CircuitModel>, CircuitModel>,
              AsyncValue<CircuitModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(circuitId: _$args));
  }
}
