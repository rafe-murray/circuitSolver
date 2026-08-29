// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'circuit_theme.dart';

class EditorCircuitThemeMapper extends ClassMapperBase<EditorCircuitTheme> {
  EditorCircuitThemeMapper._();

  static EditorCircuitThemeMapper? _instance;
  static EditorCircuitThemeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EditorCircuitThemeMapper._());
      CircuitThemeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EditorCircuitTheme';

  static double _$resistorPerpendicularSize(EditorCircuitTheme v) =>
      v.resistorPerpendicularSize;
  static const Field<EditorCircuitTheme, double> _f$resistorPerpendicularSize =
      Field(
        'resistorPerpendicularSize',
        _$resistorPerpendicularSize,
        mode: FieldMode.member,
      );
  static int _$resistorSteps(EditorCircuitTheme v) => v.resistorSteps;
  static const Field<EditorCircuitTheme, int> _f$resistorSteps = Field(
    'resistorSteps',
    _$resistorSteps,
    mode: FieldMode.member,
  );
  static double _$resistorParallelSize(EditorCircuitTheme v) =>
      v.resistorParallelSize;
  static const Field<EditorCircuitTheme, double> _f$resistorParallelSize =
      Field(
        'resistorParallelSize',
        _$resistorParallelSize,
        mode: FieldMode.member,
      );
  static double _$componentRadius(EditorCircuitTheme v) => v.componentRadius;
  static const Field<EditorCircuitTheme, double> _f$componentRadius = Field(
    'componentRadius',
    _$componentRadius,
    mode: FieldMode.member,
  );
  static VoltageSourceStyle _$voltageSourceStyle(EditorCircuitTheme v) =>
      v.voltageSourceStyle;
  static const Field<EditorCircuitTheme, VoltageSourceStyle>
  _f$voltageSourceStyle = Field(
    'voltageSourceStyle',
    _$voltageSourceStyle,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<EditorCircuitTheme> fields = const {
    #resistorPerpendicularSize: _f$resistorPerpendicularSize,
    #resistorSteps: _f$resistorSteps,
    #resistorParallelSize: _f$resistorParallelSize,
    #componentRadius: _f$componentRadius,
    #voltageSourceStyle: _f$voltageSourceStyle,
  };

  static EditorCircuitTheme _instantiate(DecodingData data) {
    return EditorCircuitTheme();
  }

  @override
  final Function instantiate = _instantiate;

  static EditorCircuitTheme fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EditorCircuitTheme>(map);
  }

  static EditorCircuitTheme fromJson(String json) {
    return ensureInitialized().decodeJson<EditorCircuitTheme>(json);
  }
}

mixin EditorCircuitThemeMappable {
  String toJson() {
    return EditorCircuitThemeMapper.ensureInitialized()
        .encodeJson<EditorCircuitTheme>(this as EditorCircuitTheme);
  }

  Map<String, dynamic> toMap() {
    return EditorCircuitThemeMapper.ensureInitialized()
        .encodeMap<EditorCircuitTheme>(this as EditorCircuitTheme);
  }

  EditorCircuitThemeCopyWith<
    EditorCircuitTheme,
    EditorCircuitTheme,
    EditorCircuitTheme
  >
  get copyWith =>
      _EditorCircuitThemeCopyWithImpl<EditorCircuitTheme, EditorCircuitTheme>(
        this as EditorCircuitTheme,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EditorCircuitThemeMapper.ensureInitialized().stringifyValue(
      this as EditorCircuitTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    return EditorCircuitThemeMapper.ensureInitialized().equalsValue(
      this as EditorCircuitTheme,
      other,
    );
  }

  @override
  int get hashCode {
    return EditorCircuitThemeMapper.ensureInitialized().hashValue(
      this as EditorCircuitTheme,
    );
  }
}

extension EditorCircuitThemeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EditorCircuitTheme, $Out> {
  EditorCircuitThemeCopyWith<$R, EditorCircuitTheme, $Out>
  get $asEditorCircuitTheme => $base.as(
    (v, t, t2) => _EditorCircuitThemeCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EditorCircuitThemeCopyWith<
  $R,
  $In extends EditorCircuitTheme,
  $Out
>
    implements CircuitThemeCopyWith<$R, $In, $Out> {
  @override
  $R call();
  EditorCircuitThemeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EditorCircuitThemeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EditorCircuitTheme, $Out>
    implements EditorCircuitThemeCopyWith<$R, EditorCircuitTheme, $Out> {
  _EditorCircuitThemeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EditorCircuitTheme> $mapper =
      EditorCircuitThemeMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  EditorCircuitTheme $make(CopyWithData data) => EditorCircuitTheme();

  @override
  EditorCircuitThemeCopyWith<$R2, EditorCircuitTheme, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EditorCircuitThemeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CircuitThemeMapper extends ClassMapperBase<CircuitTheme> {
  CircuitThemeMapper._();

  static CircuitThemeMapper? _instance;
  static CircuitThemeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CircuitThemeMapper._());
      EditorCircuitThemeMapper.ensureInitialized();
      IconCircuitThemeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CircuitTheme';

  static double _$resistorPerpendicularSize(CircuitTheme v) =>
      v.resistorPerpendicularSize;
  static const Field<CircuitTheme, double> _f$resistorPerpendicularSize = Field(
    'resistorPerpendicularSize',
    _$resistorPerpendicularSize,
  );
  static int _$resistorSteps(CircuitTheme v) => v.resistorSteps;
  static const Field<CircuitTheme, int> _f$resistorSteps = Field(
    'resistorSteps',
    _$resistorSteps,
  );
  static double _$resistorParallelSize(CircuitTheme v) =>
      v.resistorParallelSize;
  static const Field<CircuitTheme, double> _f$resistorParallelSize = Field(
    'resistorParallelSize',
    _$resistorParallelSize,
  );
  static double _$componentRadius(CircuitTheme v) => v.componentRadius;
  static const Field<CircuitTheme, double> _f$componentRadius = Field(
    'componentRadius',
    _$componentRadius,
  );
  static VoltageSourceStyle _$voltageSourceStyle(CircuitTheme v) =>
      v.voltageSourceStyle;
  static const Field<CircuitTheme, VoltageSourceStyle> _f$voltageSourceStyle =
      Field('voltageSourceStyle', _$voltageSourceStyle);

  @override
  final MappableFields<CircuitTheme> fields = const {
    #resistorPerpendicularSize: _f$resistorPerpendicularSize,
    #resistorSteps: _f$resistorSteps,
    #resistorParallelSize: _f$resistorParallelSize,
    #componentRadius: _f$componentRadius,
    #voltageSourceStyle: _f$voltageSourceStyle,
  };

  static CircuitTheme _instantiate(DecodingData data) {
    return CircuitTheme(
      resistorPerpendicularSize: data.dec(_f$resistorPerpendicularSize),
      resistorSteps: data.dec(_f$resistorSteps),
      resistorParallelSize: data.dec(_f$resistorParallelSize),
      componentRadius: data.dec(_f$componentRadius),
      voltageSourceStyle: data.dec(_f$voltageSourceStyle),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CircuitTheme fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CircuitTheme>(map);
  }

  static CircuitTheme fromJson(String json) {
    return ensureInitialized().decodeJson<CircuitTheme>(json);
  }
}

mixin CircuitThemeMappable {
  String toJson() {
    return CircuitThemeMapper.ensureInitialized().encodeJson<CircuitTheme>(
      this as CircuitTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return CircuitThemeMapper.ensureInitialized().encodeMap<CircuitTheme>(
      this as CircuitTheme,
    );
  }

  CircuitThemeCopyWith<CircuitTheme, CircuitTheme, CircuitTheme> get copyWith =>
      _CircuitThemeCopyWithImpl<CircuitTheme, CircuitTheme>(
        this as CircuitTheme,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CircuitThemeMapper.ensureInitialized().stringifyValue(
      this as CircuitTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    return CircuitThemeMapper.ensureInitialized().equalsValue(
      this as CircuitTheme,
      other,
    );
  }

  @override
  int get hashCode {
    return CircuitThemeMapper.ensureInitialized().hashValue(
      this as CircuitTheme,
    );
  }
}

extension CircuitThemeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CircuitTheme, $Out> {
  CircuitThemeCopyWith<$R, CircuitTheme, $Out> get $asCircuitTheme =>
      $base.as((v, t, t2) => _CircuitThemeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CircuitThemeCopyWith<$R, $In extends CircuitTheme, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CircuitThemeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CircuitThemeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CircuitTheme, $Out>
    implements CircuitThemeCopyWith<$R, CircuitTheme, $Out> {
  _CircuitThemeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CircuitTheme> $mapper =
      CircuitThemeMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CircuitTheme $make(CopyWithData data) => CircuitTheme(
    resistorPerpendicularSize: data.get(
      #resistorPerpendicularSize,
      or: $value.resistorPerpendicularSize,
    ),
    resistorSteps: data.get(#resistorSteps, or: $value.resistorSteps),
    resistorParallelSize: data.get(
      #resistorParallelSize,
      or: $value.resistorParallelSize,
    ),
    componentRadius: data.get(#componentRadius, or: $value.componentRadius),
    voltageSourceStyle: data.get(
      #voltageSourceStyle,
      or: $value.voltageSourceStyle,
    ),
  );

  @override
  CircuitThemeCopyWith<$R2, CircuitTheme, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CircuitThemeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IconCircuitThemeMapper extends ClassMapperBase<IconCircuitTheme> {
  IconCircuitThemeMapper._();

  static IconCircuitThemeMapper? _instance;
  static IconCircuitThemeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IconCircuitThemeMapper._());
      CircuitThemeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'IconCircuitTheme';

  static double _$resistorPerpendicularSize(IconCircuitTheme v) =>
      v.resistorPerpendicularSize;
  static const Field<IconCircuitTheme, double> _f$resistorPerpendicularSize =
      Field(
        'resistorPerpendicularSize',
        _$resistorPerpendicularSize,
        mode: FieldMode.member,
      );
  static int _$resistorSteps(IconCircuitTheme v) => v.resistorSteps;
  static const Field<IconCircuitTheme, int> _f$resistorSteps = Field(
    'resistorSteps',
    _$resistorSteps,
    mode: FieldMode.member,
  );
  static double _$resistorParallelSize(IconCircuitTheme v) =>
      v.resistorParallelSize;
  static const Field<IconCircuitTheme, double> _f$resistorParallelSize = Field(
    'resistorParallelSize',
    _$resistorParallelSize,
    mode: FieldMode.member,
  );
  static double _$componentRadius(IconCircuitTheme v) => v.componentRadius;
  static const Field<IconCircuitTheme, double> _f$componentRadius = Field(
    'componentRadius',
    _$componentRadius,
    mode: FieldMode.member,
  );
  static VoltageSourceStyle _$voltageSourceStyle(IconCircuitTheme v) =>
      v.voltageSourceStyle;
  static const Field<IconCircuitTheme, VoltageSourceStyle>
  _f$voltageSourceStyle = Field(
    'voltageSourceStyle',
    _$voltageSourceStyle,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<IconCircuitTheme> fields = const {
    #resistorPerpendicularSize: _f$resistorPerpendicularSize,
    #resistorSteps: _f$resistorSteps,
    #resistorParallelSize: _f$resistorParallelSize,
    #componentRadius: _f$componentRadius,
    #voltageSourceStyle: _f$voltageSourceStyle,
  };

  static IconCircuitTheme _instantiate(DecodingData data) {
    return IconCircuitTheme();
  }

  @override
  final Function instantiate = _instantiate;

  static IconCircuitTheme fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IconCircuitTheme>(map);
  }

  static IconCircuitTheme fromJson(String json) {
    return ensureInitialized().decodeJson<IconCircuitTheme>(json);
  }
}

mixin IconCircuitThemeMappable {
  String toJson() {
    return IconCircuitThemeMapper.ensureInitialized()
        .encodeJson<IconCircuitTheme>(this as IconCircuitTheme);
  }

  Map<String, dynamic> toMap() {
    return IconCircuitThemeMapper.ensureInitialized()
        .encodeMap<IconCircuitTheme>(this as IconCircuitTheme);
  }

  IconCircuitThemeCopyWith<IconCircuitTheme, IconCircuitTheme, IconCircuitTheme>
  get copyWith =>
      _IconCircuitThemeCopyWithImpl<IconCircuitTheme, IconCircuitTheme>(
        this as IconCircuitTheme,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IconCircuitThemeMapper.ensureInitialized().stringifyValue(
      this as IconCircuitTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    return IconCircuitThemeMapper.ensureInitialized().equalsValue(
      this as IconCircuitTheme,
      other,
    );
  }

  @override
  int get hashCode {
    return IconCircuitThemeMapper.ensureInitialized().hashValue(
      this as IconCircuitTheme,
    );
  }
}

extension IconCircuitThemeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IconCircuitTheme, $Out> {
  IconCircuitThemeCopyWith<$R, IconCircuitTheme, $Out>
  get $asIconCircuitTheme =>
      $base.as((v, t, t2) => _IconCircuitThemeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IconCircuitThemeCopyWith<$R, $In extends IconCircuitTheme, $Out>
    implements CircuitThemeCopyWith<$R, $In, $Out> {
  @override
  $R call();
  IconCircuitThemeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _IconCircuitThemeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IconCircuitTheme, $Out>
    implements IconCircuitThemeCopyWith<$R, IconCircuitTheme, $Out> {
  _IconCircuitThemeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IconCircuitTheme> $mapper =
      IconCircuitThemeMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  IconCircuitTheme $make(CopyWithData data) => IconCircuitTheme();

  @override
  IconCircuitThemeCopyWith<$R2, IconCircuitTheme, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IconCircuitThemeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

