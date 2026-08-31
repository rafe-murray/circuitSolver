// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_view_model.dart';

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

/// The tool currently active in the editor's tool bank for [circuitId], or
/// `null` when no tool is selected and canvas input is inert.

@ProviderFor(SelectedTool)
final selectedToolProvider = SelectedToolFamily._();

/// The tool currently active in the editor's tool bank for [circuitId], or
/// `null` when no tool is selected and canvas input is inert.
final class SelectedToolProvider
    extends $NotifierProvider<SelectedTool, ToolMeta?> {
  /// The tool currently active in the editor's tool bank for [circuitId], or
  /// `null` when no tool is selected and canvas input is inert.
  SelectedToolProvider._({
    required SelectedToolFamily super.from,
    required UuidValue super.argument,
  }) : super(
         retry: null,
         name: r'selectedToolProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedToolHash();

  @override
  String toString() {
    return r'selectedToolProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SelectedTool create() => SelectedTool();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolMeta? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolMeta?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedToolProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedToolHash() => r'717df89f7d27285055ac2b310ed18b17e1c218d2';

/// The tool currently active in the editor's tool bank for [circuitId], or
/// `null` when no tool is selected and canvas input is inert.

final class SelectedToolFamily extends $Family
    with
        $ClassFamilyOverride<
          SelectedTool,
          ToolMeta?,
          ToolMeta?,
          ToolMeta?,
          UuidValue
        > {
  SelectedToolFamily._()
    : super(
        retry: null,
        name: r'selectedToolProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tool currently active in the editor's tool bank for [circuitId], or
  /// `null` when no tool is selected and canvas input is inert.

  SelectedToolProvider call({required UuidValue circuitId}) =>
      SelectedToolProvider._(argument: circuitId, from: this);

  @override
  String toString() => r'selectedToolProvider';
}

/// The tool currently active in the editor's tool bank for [circuitId], or
/// `null` when no tool is selected and canvas input is inert.

abstract class _$SelectedTool extends $Notifier<ToolMeta?> {
  late final _$args = ref.$arg as UuidValue;
  UuidValue get circuitId => _$args;

  ToolMeta? build({required UuidValue circuitId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ToolMeta?, ToolMeta?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ToolMeta?, ToolMeta?>,
              ToolMeta?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(circuitId: _$args));
  }
}

/// The user's current selection of components and endpoints for [circuitId].
///
/// Transient UI state: it is not persisted and takes no part in the circuit
/// model or the undo history.

@ProviderFor(CurrentSelection)
final currentSelectionProvider = CurrentSelectionFamily._();

/// The user's current selection of components and endpoints for [circuitId].
///
/// Transient UI state: it is not persisted and takes no part in the circuit
/// model or the undo history.
final class CurrentSelectionProvider
    extends $NotifierProvider<CurrentSelection, Selection> {
  /// The user's current selection of components and endpoints for [circuitId].
  ///
  /// Transient UI state: it is not persisted and takes no part in the circuit
  /// model or the undo history.
  CurrentSelectionProvider._({
    required CurrentSelectionFamily super.from,
    required UuidValue super.argument,
  }) : super(
         retry: null,
         name: r'currentSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentSelectionHash();

  @override
  String toString() {
    return r'currentSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CurrentSelection create() => CurrentSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Selection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Selection>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentSelectionHash() => r'ab4bc2fdabc80aeb4ba456a783dd3f3378f2c38e';

/// The user's current selection of components and endpoints for [circuitId].
///
/// Transient UI state: it is not persisted and takes no part in the circuit
/// model or the undo history.

final class CurrentSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          CurrentSelection,
          Selection,
          Selection,
          Selection,
          UuidValue
        > {
  CurrentSelectionFamily._()
    : super(
        retry: null,
        name: r'currentSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The user's current selection of components and endpoints for [circuitId].
  ///
  /// Transient UI state: it is not persisted and takes no part in the circuit
  /// model or the undo history.

  CurrentSelectionProvider call({required UuidValue circuitId}) =>
      CurrentSelectionProvider._(argument: circuitId, from: this);

  @override
  String toString() => r'currentSelectionProvider';
}

/// The user's current selection of components and endpoints for [circuitId].
///
/// Transient UI state: it is not persisted and takes no part in the circuit
/// model or the undo history.

abstract class _$CurrentSelection extends $Notifier<Selection> {
  late final _$args = ref.$arg as UuidValue;
  UuidValue get circuitId => _$args;

  Selection build({required UuidValue circuitId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Selection, Selection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Selection, Selection>,
              Selection,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(circuitId: _$args));
  }
}

@ProviderFor(EditorViewModel)
final editorViewModelProvider = EditorViewModelFamily._();

final class EditorViewModelProvider
    extends $AsyncNotifierProvider<EditorViewModel, CircuitModel> {
  EditorViewModelProvider._({
    required EditorViewModelFamily super.from,
    required UuidValue super.argument,
  }) : super(
         retry: null,
         name: r'editorViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorViewModelHash();

  @override
  String toString() {
    return r'editorViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorViewModel create() => EditorViewModel();

  @override
  bool operator ==(Object other) {
    return other is EditorViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorViewModelHash() => r'089f91dd4fdace13197ea4d18b8a95f6d6ac4965';

final class EditorViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorViewModel,
          AsyncValue<CircuitModel>,
          CircuitModel,
          FutureOr<CircuitModel>,
          UuidValue
        > {
  EditorViewModelFamily._()
    : super(
        retry: null,
        name: r'editorViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EditorViewModelProvider call({required UuidValue circuitId}) =>
      EditorViewModelProvider._(argument: circuitId, from: this);

  @override
  String toString() => r'editorViewModelProvider';
}

abstract class _$EditorViewModel extends $AsyncNotifier<CircuitModel> {
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
