// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(circuitId)
final circuitIdProvider = CircuitIdProvider._();

final class CircuitIdProvider
    extends $FunctionalProvider<UuidValue, UuidValue, UuidValue>
    with $Provider<UuidValue> {
  CircuitIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'circuitIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$circuitIdHash();

  @$internal
  @override
  $ProviderElement<UuidValue> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UuidValue create(Ref ref) {
    return circuitId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UuidValue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UuidValue>(value),
    );
  }
}

String _$circuitIdHash() => r'9a15b236d5f745a35fa2c47e6785dad41cdeb86e';
