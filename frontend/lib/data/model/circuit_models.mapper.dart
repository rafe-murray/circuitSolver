// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'circuit_models.dart';

class CircuitModelMapper extends ClassMapperBase<CircuitModel> {
  CircuitModelMapper._();

  static CircuitModelMapper? _instance;
  static CircuitModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CircuitModelMapper._());
      MapperContainer.globals.useAll([UuidValueMapper()]);
      ComponentModelMapper.ensureInitialized();
      WireModelMapper.ensureInitialized();
      EndpointModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CircuitModel';

  static UuidValue _$id(CircuitModel v) => v.id;
  static const Field<CircuitModel, UuidValue> _f$id = Field('id', _$id);
  static String? _$name(CircuitModel v) => v.name;
  static const Field<CircuitModel, String> _f$name = Field('name', _$name);
  static List<ComponentModel> _$components(CircuitModel v) => v.components;
  static const Field<CircuitModel, List<ComponentModel>> _f$components = Field(
    'components',
    _$components,
  );
  static List<WireModel> _$wires(CircuitModel v) => v.wires;
  static const Field<CircuitModel, List<WireModel>> _f$wires = Field(
    'wires',
    _$wires,
  );
  static Map<UuidValue, EndpointModel> _$endpoints(CircuitModel v) =>
      v.endpoints;
  static const Field<CircuitModel, Map<UuidValue, EndpointModel>> _f$endpoints =
      Field('endpoints', _$endpoints);

  @override
  final MappableFields<CircuitModel> fields = const {
    #id: _f$id,
    #name: _f$name,
    #components: _f$components,
    #wires: _f$wires,
    #endpoints: _f$endpoints,
  };

  static CircuitModel _instantiate(DecodingData data) {
    return CircuitModel(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      components: data.dec(_f$components),
      wires: data.dec(_f$wires),
      endpoints: data.dec(_f$endpoints),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CircuitModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CircuitModel>(map);
  }

  static CircuitModel fromJson(String json) {
    return ensureInitialized().decodeJson<CircuitModel>(json);
  }
}

mixin CircuitModelMappable {
  String toJson() {
    return CircuitModelMapper.ensureInitialized().encodeJson<CircuitModel>(
      this as CircuitModel,
    );
  }

  Map<String, dynamic> toMap() {
    return CircuitModelMapper.ensureInitialized().encodeMap<CircuitModel>(
      this as CircuitModel,
    );
  }

  CircuitModelCopyWith<CircuitModel, CircuitModel, CircuitModel> get copyWith =>
      _CircuitModelCopyWithImpl<CircuitModel, CircuitModel>(
        this as CircuitModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CircuitModelMapper.ensureInitialized().stringifyValue(
      this as CircuitModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return CircuitModelMapper.ensureInitialized().equalsValue(
      this as CircuitModel,
      other,
    );
  }

  @override
  int get hashCode {
    return CircuitModelMapper.ensureInitialized().hashValue(
      this as CircuitModel,
    );
  }
}

extension CircuitModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CircuitModel, $Out> {
  CircuitModelCopyWith<$R, CircuitModel, $Out> get $asCircuitModel =>
      $base.as((v, t, t2) => _CircuitModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CircuitModelCopyWith<$R, $In extends CircuitModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ComponentModel,
    ComponentModelCopyWith<$R, ComponentModel, ComponentModel>
  >
  get components;
  ListCopyWith<$R, WireModel, WireModelCopyWith<$R, WireModel, WireModel>>
  get wires;
  MapCopyWith<
    $R,
    UuidValue,
    EndpointModel,
    EndpointModelCopyWith<$R, EndpointModel, EndpointModel>
  >
  get endpoints;
  $R call({
    UuidValue? id,
    String? name,
    List<ComponentModel>? components,
    List<WireModel>? wires,
    Map<UuidValue, EndpointModel>? endpoints,
  });
  CircuitModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CircuitModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CircuitModel, $Out>
    implements CircuitModelCopyWith<$R, CircuitModel, $Out> {
  _CircuitModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CircuitModel> $mapper =
      CircuitModelMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ComponentModel,
    ComponentModelCopyWith<$R, ComponentModel, ComponentModel>
  >
  get components => ListCopyWith(
    $value.components,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(components: v),
  );
  @override
  ListCopyWith<$R, WireModel, WireModelCopyWith<$R, WireModel, WireModel>>
  get wires => ListCopyWith(
    $value.wires,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(wires: v),
  );
  @override
  MapCopyWith<
    $R,
    UuidValue,
    EndpointModel,
    EndpointModelCopyWith<$R, EndpointModel, EndpointModel>
  >
  get endpoints => MapCopyWith(
    $value.endpoints,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(endpoints: v),
  );
  @override
  $R call({
    UuidValue? id,
    Object? name = $none,
    List<ComponentModel>? components,
    List<WireModel>? wires,
    Map<UuidValue, EndpointModel>? endpoints,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != $none) #name: name,
      if (components != null) #components: components,
      if (wires != null) #wires: wires,
      if (endpoints != null) #endpoints: endpoints,
    }),
  );
  @override
  CircuitModel $make(CopyWithData data) => CircuitModel(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    components: data.get(#components, or: $value.components),
    wires: data.get(#wires, or: $value.wires),
    endpoints: data.get(#endpoints, or: $value.endpoints),
  );

  @override
  CircuitModelCopyWith<$R2, CircuitModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CircuitModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ComponentModelMapper extends ClassMapperBase<ComponentModel> {
  ComponentModelMapper._();

  static ComponentModelMapper? _instance;
  static ComponentModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ComponentModelMapper._());
      BranchModelMapper.ensureInitialized();
      CurrentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ComponentModel';

  static UuidValue _$id(ComponentModel v) => v.id;
  static const Field<ComponentModel, UuidValue> _f$id = Field('id', _$id);
  static UuidValue _$fromId(ComponentModel v) => v.fromId;
  static const Field<ComponentModel, UuidValue> _f$fromId = Field(
    'fromId',
    _$fromId,
  );
  static UuidValue _$toId(ComponentModel v) => v.toId;
  static const Field<ComponentModel, UuidValue> _f$toId = Field('toId', _$toId);
  static BranchModel _$branch(ComponentModel v) => v.branch;
  static const Field<ComponentModel, BranchModel> _f$branch = Field(
    'branch',
    _$branch,
  );
  static Current? _$current(ComponentModel v) => v.current;
  static const Field<ComponentModel, Current> _f$current = Field(
    'current',
    _$current,
    opt: true,
  );

  @override
  final MappableFields<ComponentModel> fields = const {
    #id: _f$id,
    #fromId: _f$fromId,
    #toId: _f$toId,
    #branch: _f$branch,
    #current: _f$current,
  };

  static ComponentModel _instantiate(DecodingData data) {
    return ComponentModel(
      id: data.dec(_f$id),
      fromId: data.dec(_f$fromId),
      toId: data.dec(_f$toId),
      branch: data.dec(_f$branch),
      current: data.dec(_f$current),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ComponentModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ComponentModel>(map);
  }

  static ComponentModel fromJson(String json) {
    return ensureInitialized().decodeJson<ComponentModel>(json);
  }
}

mixin ComponentModelMappable {
  String toJson() {
    return ComponentModelMapper.ensureInitialized().encodeJson<ComponentModel>(
      this as ComponentModel,
    );
  }

  Map<String, dynamic> toMap() {
    return ComponentModelMapper.ensureInitialized().encodeMap<ComponentModel>(
      this as ComponentModel,
    );
  }

  ComponentModelCopyWith<ComponentModel, ComponentModel, ComponentModel>
  get copyWith => _ComponentModelCopyWithImpl<ComponentModel, ComponentModel>(
    this as ComponentModel,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ComponentModelMapper.ensureInitialized().stringifyValue(
      this as ComponentModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return ComponentModelMapper.ensureInitialized().equalsValue(
      this as ComponentModel,
      other,
    );
  }

  @override
  int get hashCode {
    return ComponentModelMapper.ensureInitialized().hashValue(
      this as ComponentModel,
    );
  }
}

extension ComponentModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ComponentModel, $Out> {
  ComponentModelCopyWith<$R, ComponentModel, $Out> get $asComponentModel =>
      $base.as((v, t, t2) => _ComponentModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ComponentModelCopyWith<$R, $In extends ComponentModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  BranchModelCopyWith<$R, BranchModel, BranchModel> get branch;
  CurrentCopyWith<$R, Current, Current>? get current;
  $R call({
    UuidValue? id,
    UuidValue? fromId,
    UuidValue? toId,
    BranchModel? branch,
    Current? current,
  });
  ComponentModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ComponentModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ComponentModel, $Out>
    implements ComponentModelCopyWith<$R, ComponentModel, $Out> {
  _ComponentModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ComponentModel> $mapper =
      ComponentModelMapper.ensureInitialized();
  @override
  BranchModelCopyWith<$R, BranchModel, BranchModel> get branch =>
      $value.branch.copyWith.$chain((v) => call(branch: v));
  @override
  CurrentCopyWith<$R, Current, Current>? get current =>
      $value.current?.copyWith.$chain((v) => call(current: v));
  @override
  $R call({
    UuidValue? id,
    UuidValue? fromId,
    UuidValue? toId,
    BranchModel? branch,
    Object? current = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (fromId != null) #fromId: fromId,
      if (toId != null) #toId: toId,
      if (branch != null) #branch: branch,
      if (current != $none) #current: current,
    }),
  );
  @override
  ComponentModel $make(CopyWithData data) => ComponentModel(
    id: data.get(#id, or: $value.id),
    fromId: data.get(#fromId, or: $value.fromId),
    toId: data.get(#toId, or: $value.toId),
    branch: data.get(#branch, or: $value.branch),
    current: data.get(#current, or: $value.current),
  );

  @override
  ComponentModelCopyWith<$R2, ComponentModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ComponentModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BranchModelMapper extends ClassMapperBase<BranchModel> {
  BranchModelMapper._();

  static BranchModelMapper? _instance;
  static BranchModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BranchModelMapper._());
      CurrentSourceMapper.ensureInitialized();
      IdealDiodeMapper.ensureInitialized();
      ResistorMapper.ensureInitialized();
      RealDiodeMapper.ensureInitialized();
      VoltageSourceMapper.ensureInitialized();
      ZenerDiodeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BranchModel';

  @override
  final MappableFields<BranchModel> fields = const {};

  static BranchModel _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'BranchModel',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BranchModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BranchModel>(map);
  }

  static BranchModel fromJson(String json) {
    return ensureInitialized().decodeJson<BranchModel>(json);
  }
}

mixin BranchModelMappable {
  String toJson();
  Map<String, dynamic> toMap();
  BranchModelCopyWith<BranchModel, BranchModel, BranchModel> get copyWith;
}

abstract class BranchModelCopyWith<$R, $In extends BranchModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  BranchModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class CurrentMapper extends ClassMapperBase<Current> {
  CurrentMapper._();

  static CurrentMapper? _instance;
  static CurrentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CurrentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Current';

  static double _$a(Current v) => v.a;
  static const Field<Current, double> _f$a = Field('a', _$a);

  @override
  final MappableFields<Current> fields = const {#a: _f$a};

  static Current _instantiate(DecodingData data) {
    return Current(a: data.dec(_f$a));
  }

  @override
  final Function instantiate = _instantiate;

  static Current fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Current>(map);
  }

  static Current fromJson(String json) {
    return ensureInitialized().decodeJson<Current>(json);
  }
}

mixin CurrentMappable {
  String toJson() {
    return CurrentMapper.ensureInitialized().encodeJson<Current>(
      this as Current,
    );
  }

  Map<String, dynamic> toMap() {
    return CurrentMapper.ensureInitialized().encodeMap<Current>(
      this as Current,
    );
  }

  CurrentCopyWith<Current, Current, Current> get copyWith =>
      _CurrentCopyWithImpl<Current, Current>(
        this as Current,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CurrentMapper.ensureInitialized().stringifyValue(this as Current);
  }

  @override
  bool operator ==(Object other) {
    return CurrentMapper.ensureInitialized().equalsValue(
      this as Current,
      other,
    );
  }

  @override
  int get hashCode {
    return CurrentMapper.ensureInitialized().hashValue(this as Current);
  }
}

extension CurrentValueCopy<$R, $Out> on ObjectCopyWith<$R, Current, $Out> {
  CurrentCopyWith<$R, Current, $Out> get $asCurrent =>
      $base.as((v, t, t2) => _CurrentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CurrentCopyWith<$R, $In extends Current, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? a});
  CurrentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CurrentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Current, $Out>
    implements CurrentCopyWith<$R, Current, $Out> {
  _CurrentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Current> $mapper =
      CurrentMapper.ensureInitialized();
  @override
  $R call({double? a}) => $apply(FieldCopyWithData({if (a != null) #a: a}));
  @override
  Current $make(CopyWithData data) => Current(a: data.get(#a, or: $value.a));

  @override
  CurrentCopyWith<$R2, Current, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CurrentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WireModelMapper extends ClassMapperBase<WireModel> {
  WireModelMapper._();

  static WireModelMapper? _instance;
  static WireModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WireModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'WireModel';

  static UuidValue _$id(WireModel v) => v.id;
  static const Field<WireModel, UuidValue> _f$id = Field('id', _$id);
  static UuidValue _$endpoint1Id(WireModel v) => v.endpoint1Id;
  static const Field<WireModel, UuidValue> _f$endpoint1Id = Field(
    'endpoint1Id',
    _$endpoint1Id,
  );
  static UuidValue _$endpoint2Id(WireModel v) => v.endpoint2Id;
  static const Field<WireModel, UuidValue> _f$endpoint2Id = Field(
    'endpoint2Id',
    _$endpoint2Id,
  );

  @override
  final MappableFields<WireModel> fields = const {
    #id: _f$id,
    #endpoint1Id: _f$endpoint1Id,
    #endpoint2Id: _f$endpoint2Id,
  };

  static WireModel _instantiate(DecodingData data) {
    return WireModel(
      id: data.dec(_f$id),
      endpoint1Id: data.dec(_f$endpoint1Id),
      endpoint2Id: data.dec(_f$endpoint2Id),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WireModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WireModel>(map);
  }

  static WireModel fromJson(String json) {
    return ensureInitialized().decodeJson<WireModel>(json);
  }
}

mixin WireModelMappable {
  String toJson() {
    return WireModelMapper.ensureInitialized().encodeJson<WireModel>(
      this as WireModel,
    );
  }

  Map<String, dynamic> toMap() {
    return WireModelMapper.ensureInitialized().encodeMap<WireModel>(
      this as WireModel,
    );
  }

  WireModelCopyWith<WireModel, WireModel, WireModel> get copyWith =>
      _WireModelCopyWithImpl<WireModel, WireModel>(
        this as WireModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WireModelMapper.ensureInitialized().stringifyValue(
      this as WireModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return WireModelMapper.ensureInitialized().equalsValue(
      this as WireModel,
      other,
    );
  }

  @override
  int get hashCode {
    return WireModelMapper.ensureInitialized().hashValue(this as WireModel);
  }
}

extension WireModelValueCopy<$R, $Out> on ObjectCopyWith<$R, WireModel, $Out> {
  WireModelCopyWith<$R, WireModel, $Out> get $asWireModel =>
      $base.as((v, t, t2) => _WireModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WireModelCopyWith<$R, $In extends WireModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({UuidValue? id, UuidValue? endpoint1Id, UuidValue? endpoint2Id});
  WireModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WireModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WireModel, $Out>
    implements WireModelCopyWith<$R, WireModel, $Out> {
  _WireModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WireModel> $mapper =
      WireModelMapper.ensureInitialized();
  @override
  $R call({UuidValue? id, UuidValue? endpoint1Id, UuidValue? endpoint2Id}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (endpoint1Id != null) #endpoint1Id: endpoint1Id,
          if (endpoint2Id != null) #endpoint2Id: endpoint2Id,
        }),
      );
  @override
  WireModel $make(CopyWithData data) => WireModel(
    id: data.get(#id, or: $value.id),
    endpoint1Id: data.get(#endpoint1Id, or: $value.endpoint1Id),
    endpoint2Id: data.get(#endpoint2Id, or: $value.endpoint2Id),
  );

  @override
  WireModelCopyWith<$R2, WireModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WireModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EndpointModelMapper extends ClassMapperBase<EndpointModel> {
  EndpointModelMapper._();

  static EndpointModelMapper? _instance;
  static EndpointModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EndpointModelMapper._());
      MapperContainer.globals.useAll([OffsetMapper()]);
      VoltageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EndpointModel';

  static Offset _$pos(EndpointModel v) => v.pos;
  static const Field<EndpointModel, Offset> _f$pos = Field('pos', _$pos);
  static UuidValue _$id(EndpointModel v) => v.id;
  static const Field<EndpointModel, UuidValue> _f$id = Field('id', _$id);
  static Voltage? _$voltage(EndpointModel v) => v.voltage;
  static const Field<EndpointModel, Voltage> _f$voltage = Field(
    'voltage',
    _$voltage,
    opt: true,
  );

  @override
  final MappableFields<EndpointModel> fields = const {
    #pos: _f$pos,
    #id: _f$id,
    #voltage: _f$voltage,
  };

  static EndpointModel _instantiate(DecodingData data) {
    return EndpointModel(
      pos: data.dec(_f$pos),
      id: data.dec(_f$id),
      voltage: data.dec(_f$voltage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EndpointModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EndpointModel>(map);
  }

  static EndpointModel fromJson(String json) {
    return ensureInitialized().decodeJson<EndpointModel>(json);
  }
}

mixin EndpointModelMappable {
  String toJson() {
    return EndpointModelMapper.ensureInitialized().encodeJson<EndpointModel>(
      this as EndpointModel,
    );
  }

  Map<String, dynamic> toMap() {
    return EndpointModelMapper.ensureInitialized().encodeMap<EndpointModel>(
      this as EndpointModel,
    );
  }

  EndpointModelCopyWith<EndpointModel, EndpointModel, EndpointModel>
  get copyWith => _EndpointModelCopyWithImpl<EndpointModel, EndpointModel>(
    this as EndpointModel,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EndpointModelMapper.ensureInitialized().stringifyValue(
      this as EndpointModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return EndpointModelMapper.ensureInitialized().equalsValue(
      this as EndpointModel,
      other,
    );
  }

  @override
  int get hashCode {
    return EndpointModelMapper.ensureInitialized().hashValue(
      this as EndpointModel,
    );
  }
}

extension EndpointModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EndpointModel, $Out> {
  EndpointModelCopyWith<$R, EndpointModel, $Out> get $asEndpointModel =>
      $base.as((v, t, t2) => _EndpointModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EndpointModelCopyWith<$R, $In extends EndpointModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage;
  $R call({Offset? pos, UuidValue? id, Voltage? voltage});
  EndpointModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EndpointModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EndpointModel, $Out>
    implements EndpointModelCopyWith<$R, EndpointModel, $Out> {
  _EndpointModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EndpointModel> $mapper =
      EndpointModelMapper.ensureInitialized();
  @override
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage =>
      $value.voltage?.copyWith.$chain((v) => call(voltage: v));
  @override
  $R call({Offset? pos, UuidValue? id, Object? voltage = $none}) => $apply(
    FieldCopyWithData({
      if (pos != null) #pos: pos,
      if (id != null) #id: id,
      if (voltage != $none) #voltage: voltage,
    }),
  );
  @override
  EndpointModel $make(CopyWithData data) => EndpointModel(
    pos: data.get(#pos, or: $value.pos),
    id: data.get(#id, or: $value.id),
    voltage: data.get(#voltage, or: $value.voltage),
  );

  @override
  EndpointModelCopyWith<$R2, EndpointModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EndpointModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VoltageMapper extends ClassMapperBase<Voltage> {
  VoltageMapper._();

  static VoltageMapper? _instance;
  static VoltageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VoltageMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Voltage';

  static double _$volts(Voltage v) => v.volts;
  static const Field<Voltage, double> _f$volts = Field('volts', _$volts);

  @override
  final MappableFields<Voltage> fields = const {#volts: _f$volts};

  static Voltage _instantiate(DecodingData data) {
    return Voltage(volts: data.dec(_f$volts));
  }

  @override
  final Function instantiate = _instantiate;

  static Voltage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Voltage>(map);
  }

  static Voltage fromJson(String json) {
    return ensureInitialized().decodeJson<Voltage>(json);
  }
}

mixin VoltageMappable {
  String toJson() {
    return VoltageMapper.ensureInitialized().encodeJson<Voltage>(
      this as Voltage,
    );
  }

  Map<String, dynamic> toMap() {
    return VoltageMapper.ensureInitialized().encodeMap<Voltage>(
      this as Voltage,
    );
  }

  VoltageCopyWith<Voltage, Voltage, Voltage> get copyWith =>
      _VoltageCopyWithImpl<Voltage, Voltage>(
        this as Voltage,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VoltageMapper.ensureInitialized().stringifyValue(this as Voltage);
  }

  @override
  bool operator ==(Object other) {
    return VoltageMapper.ensureInitialized().equalsValue(
      this as Voltage,
      other,
    );
  }

  @override
  int get hashCode {
    return VoltageMapper.ensureInitialized().hashValue(this as Voltage);
  }
}

extension VoltageValueCopy<$R, $Out> on ObjectCopyWith<$R, Voltage, $Out> {
  VoltageCopyWith<$R, Voltage, $Out> get $asVoltage =>
      $base.as((v, t, t2) => _VoltageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VoltageCopyWith<$R, $In extends Voltage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? volts});
  VoltageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VoltageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Voltage, $Out>
    implements VoltageCopyWith<$R, Voltage, $Out> {
  _VoltageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Voltage> $mapper =
      VoltageMapper.ensureInitialized();
  @override
  $R call({double? volts}) =>
      $apply(FieldCopyWithData({if (volts != null) #volts: volts}));
  @override
  Voltage $make(CopyWithData data) =>
      Voltage(volts: data.get(#volts, or: $value.volts));

  @override
  VoltageCopyWith<$R2, Voltage, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _VoltageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PatchMapper extends ClassMapperBase<Patch> {
  PatchMapper._();

  static PatchMapper? _instance;
  static PatchMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PatchMapper._());
      AddMapper.ensureInitialized();
      RemoveMapper.ensureInitialized();
      ChangeMapper.ensureInitialized();
      ReplaceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Patch';
  @override
  Function get typeFactory =>
      <K, V>(f) => f<Patch<K, V>>();

  @override
  final MappableFields<Patch> fields = const {};

  static Patch<K, V> _instantiate<K, V>(DecodingData data) {
    throw MapperException.missingSubclass(
      'Patch',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Patch<K, V> fromMap<K, V>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Patch<K, V>>(map);
  }

  static Patch<K, V> fromJson<K, V>(String json) {
    return ensureInitialized().decodeJson<Patch<K, V>>(json);
  }
}

mixin PatchMappable<K, V> {
  String toJson();
  Map<String, dynamic> toMap();
  PatchCopyWith<Patch<K, V>, Patch<K, V>, Patch<K, V>, K, V> get copyWith;
}

abstract class PatchCopyWith<$R, $In extends Patch<K, V>, $Out, K, V>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  PatchCopyWith<$R2, $In, $Out2, K, V> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class AddMapper extends SubClassMapperBase<Add> {
  AddMapper._();

  static AddMapper? _instance;
  static AddMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddMapper._());
      PatchMapper.ensureInitialized().addSubMapper(_instance!);
      _t$_R0Mapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Add';
  @override
  Function get typeFactory =>
      <K, V>(f) => f<Add<K, V>>();

  static Iterable<_t$_R0<dynamic, dynamic>> _$value(Add v) => v.value;
  static dynamic _arg$value<K, V>(f) => f<Iterable<_t$_R0<K, V>>>();
  static const Field<Add, Iterable<_t$_R0<dynamic, dynamic>>> _f$value = Field(
    'value',
    _$value,
    arg: _arg$value,
  );

  @override
  final MappableFields<Add> fields = const {#value: _f$value};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'add';
  @override
  late final ClassMapperBase superMapper = PatchMapper.ensureInitialized();

  static Add<K, V> _instantiate<K, V>(DecodingData data) {
    return Add(value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static Add<K, V> fromMap<K, V>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Add<K, V>>(map);
  }

  static Add<K, V> fromJson<K, V>(String json) {
    return ensureInitialized().decodeJson<Add<K, V>>(json);
  }
}

mixin AddMappable<K, V> {
  String toJson() {
    return AddMapper.ensureInitialized().encodeJson<Add<K, V>>(
      this as Add<K, V>,
    );
  }

  Map<String, dynamic> toMap() {
    return AddMapper.ensureInitialized().encodeMap<Add<K, V>>(
      this as Add<K, V>,
    );
  }

  AddCopyWith<Add<K, V>, Add<K, V>, Add<K, V>, K, V> get copyWith =>
      _AddCopyWithImpl<Add<K, V>, Add<K, V>, K, V>(
        this as Add<K, V>,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AddMapper.ensureInitialized().stringifyValue(this as Add<K, V>);
  }

  @override
  bool operator ==(Object other) {
    return AddMapper.ensureInitialized().equalsValue(this as Add<K, V>, other);
  }

  @override
  int get hashCode {
    return AddMapper.ensureInitialized().hashValue(this as Add<K, V>);
  }
}

extension AddValueCopy<$R, $Out, K, V> on ObjectCopyWith<$R, Add<K, V>, $Out> {
  AddCopyWith<$R, Add<K, V>, $Out, K, V> get $asAdd =>
      $base.as((v, t, t2) => _AddCopyWithImpl<$R, $Out, K, V>(v, t, t2));
}

abstract class AddCopyWith<$R, $In extends Add<K, V>, $Out, K, V>
    implements PatchCopyWith<$R, $In, $Out, K, V> {
  @override
  $R call({Iterable<_t$_R0<K, V>>? value});
  AddCopyWith<$R2, $In, $Out2, K, V> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AddCopyWithImpl<$R, $Out, K, V>
    extends ClassCopyWithBase<$R, Add<K, V>, $Out>
    implements AddCopyWith<$R, Add<K, V>, $Out, K, V> {
  _AddCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Add> $mapper = AddMapper.ensureInitialized();
  @override
  $R call({Iterable<_t$_R0<K, V>>? value}) =>
      $apply(FieldCopyWithData({if (value != null) #value: value}));
  @override
  Add<K, V> $make(CopyWithData data) =>
      Add(value: data.get(#value, or: $value.value));

  @override
  AddCopyWith<$R2, Add<K, V>, $Out2, K, V> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AddCopyWithImpl<$R2, $Out2, K, V>($value, $cast, t);
}

class RemoveMapper extends SubClassMapperBase<Remove> {
  RemoveMapper._();

  static RemoveMapper? _instance;
  static RemoveMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RemoveMapper._());
      PatchMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Remove';
  @override
  Function get typeFactory =>
      <K, V>(f) => f<Remove<K, V>>();

  static dynamic _$position(Remove v) => v.position;
  static dynamic _arg$position<K, V>(f) => f<K>();
  static const Field<Remove, dynamic> _f$position = Field(
    'position',
    _$position,
    arg: _arg$position,
  );

  @override
  final MappableFields<Remove> fields = const {#position: _f$position};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'remove';
  @override
  late final ClassMapperBase superMapper = PatchMapper.ensureInitialized();

  static Remove<K, V> _instantiate<K, V>(DecodingData data) {
    return Remove(position: data.dec(_f$position));
  }

  @override
  final Function instantiate = _instantiate;

  static Remove<K, V> fromMap<K, V>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Remove<K, V>>(map);
  }

  static Remove<K, V> fromJson<K, V>(String json) {
    return ensureInitialized().decodeJson<Remove<K, V>>(json);
  }
}

mixin RemoveMappable<K, V> {
  String toJson() {
    return RemoveMapper.ensureInitialized().encodeJson<Remove<K, V>>(
      this as Remove<K, V>,
    );
  }

  Map<String, dynamic> toMap() {
    return RemoveMapper.ensureInitialized().encodeMap<Remove<K, V>>(
      this as Remove<K, V>,
    );
  }

  RemoveCopyWith<Remove<K, V>, Remove<K, V>, Remove<K, V>, K, V> get copyWith =>
      _RemoveCopyWithImpl<Remove<K, V>, Remove<K, V>, K, V>(
        this as Remove<K, V>,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RemoveMapper.ensureInitialized().stringifyValue(
      this as Remove<K, V>,
    );
  }

  @override
  bool operator ==(Object other) {
    return RemoveMapper.ensureInitialized().equalsValue(
      this as Remove<K, V>,
      other,
    );
  }

  @override
  int get hashCode {
    return RemoveMapper.ensureInitialized().hashValue(this as Remove<K, V>);
  }
}

extension RemoveValueCopy<$R, $Out, K, V>
    on ObjectCopyWith<$R, Remove<K, V>, $Out> {
  RemoveCopyWith<$R, Remove<K, V>, $Out, K, V> get $asRemove =>
      $base.as((v, t, t2) => _RemoveCopyWithImpl<$R, $Out, K, V>(v, t, t2));
}

abstract class RemoveCopyWith<$R, $In extends Remove<K, V>, $Out, K, V>
    implements PatchCopyWith<$R, $In, $Out, K, V> {
  @override
  $R call({K? position});
  RemoveCopyWith<$R2, $In, $Out2, K, V> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RemoveCopyWithImpl<$R, $Out, K, V>
    extends ClassCopyWithBase<$R, Remove<K, V>, $Out>
    implements RemoveCopyWith<$R, Remove<K, V>, $Out, K, V> {
  _RemoveCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Remove> $mapper = RemoveMapper.ensureInitialized();
  @override
  $R call({Object? position = $none}) =>
      $apply(FieldCopyWithData({if (position != $none) #position: position}));
  @override
  Remove<K, V> $make(CopyWithData data) =>
      Remove(position: data.get(#position, or: $value.position));

  @override
  RemoveCopyWith<$R2, Remove<K, V>, $Out2, K, V> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RemoveCopyWithImpl<$R2, $Out2, K, V>($value, $cast, t);
}

class ChangeMapper extends SubClassMapperBase<Change> {
  ChangeMapper._();

  static ChangeMapper? _instance;
  static ChangeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChangeMapper._());
      PatchMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Change';
  @override
  Function get typeFactory =>
      <K, V>(f) => f<Change<K, V>>();

  static dynamic _$position(Change v) => v.position;
  static dynamic _arg$position<K, V>(f) => f<K>();
  static const Field<Change, dynamic> _f$position = Field(
    'position',
    _$position,
    arg: _arg$position,
  );
  static dynamic _$value(Change v) => v.value;
  static dynamic _arg$value<K, V>(f) => f<V>();
  static const Field<Change, dynamic> _f$value = Field(
    'value',
    _$value,
    arg: _arg$value,
  );

  @override
  final MappableFields<Change> fields = const {
    #position: _f$position,
    #value: _f$value,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'change';
  @override
  late final ClassMapperBase superMapper = PatchMapper.ensureInitialized();

  static Change<K, V> _instantiate<K, V>(DecodingData data) {
    return Change(position: data.dec(_f$position), value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static Change<K, V> fromMap<K, V>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Change<K, V>>(map);
  }

  static Change<K, V> fromJson<K, V>(String json) {
    return ensureInitialized().decodeJson<Change<K, V>>(json);
  }
}

mixin ChangeMappable<K, V> {
  String toJson() {
    return ChangeMapper.ensureInitialized().encodeJson<Change<K, V>>(
      this as Change<K, V>,
    );
  }

  Map<String, dynamic> toMap() {
    return ChangeMapper.ensureInitialized().encodeMap<Change<K, V>>(
      this as Change<K, V>,
    );
  }

  ChangeCopyWith<Change<K, V>, Change<K, V>, Change<K, V>, K, V> get copyWith =>
      _ChangeCopyWithImpl<Change<K, V>, Change<K, V>, K, V>(
        this as Change<K, V>,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChangeMapper.ensureInitialized().stringifyValue(
      this as Change<K, V>,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChangeMapper.ensureInitialized().equalsValue(
      this as Change<K, V>,
      other,
    );
  }

  @override
  int get hashCode {
    return ChangeMapper.ensureInitialized().hashValue(this as Change<K, V>);
  }
}

extension ChangeValueCopy<$R, $Out, K, V>
    on ObjectCopyWith<$R, Change<K, V>, $Out> {
  ChangeCopyWith<$R, Change<K, V>, $Out, K, V> get $asChange =>
      $base.as((v, t, t2) => _ChangeCopyWithImpl<$R, $Out, K, V>(v, t, t2));
}

abstract class ChangeCopyWith<$R, $In extends Change<K, V>, $Out, K, V>
    implements PatchCopyWith<$R, $In, $Out, K, V> {
  @override
  $R call({K? position, V? value});
  ChangeCopyWith<$R2, $In, $Out2, K, V> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChangeCopyWithImpl<$R, $Out, K, V>
    extends ClassCopyWithBase<$R, Change<K, V>, $Out>
    implements ChangeCopyWith<$R, Change<K, V>, $Out, K, V> {
  _ChangeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Change> $mapper = ChangeMapper.ensureInitialized();
  @override
  $R call({Object? position = $none, Object? value = $none}) => $apply(
    FieldCopyWithData({
      if (position != $none) #position: position,
      if (value != $none) #value: value,
    }),
  );
  @override
  Change<K, V> $make(CopyWithData data) => Change(
    position: data.get(#position, or: $value.position),
    value: data.get(#value, or: $value.value),
  );

  @override
  ChangeCopyWith<$R2, Change<K, V>, $Out2, K, V> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChangeCopyWithImpl<$R2, $Out2, K, V>($value, $cast, t);
}

class ReplaceMapper extends SubClassMapperBase<Replace> {
  ReplaceMapper._();

  static ReplaceMapper? _instance;
  static ReplaceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReplaceMapper._());
      PatchMapper.ensureInitialized().addSubMapper(_instance!);
      _t$_R0Mapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Replace';
  @override
  Function get typeFactory =>
      <K, V>(f) => f<Replace<K, V>>();

  static Iterable<_t$_R0<dynamic, dynamic>> _$values(Replace v) => v.values;
  static dynamic _arg$values<K, V>(f) => f<Iterable<_t$_R0<K, V>>>();
  static const Field<Replace, Iterable<_t$_R0<dynamic, dynamic>>> _f$values =
      Field('values', _$values, arg: _arg$values);

  @override
  final MappableFields<Replace> fields = const {#values: _f$values};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'replace';
  @override
  late final ClassMapperBase superMapper = PatchMapper.ensureInitialized();

  static Replace<K, V> _instantiate<K, V>(DecodingData data) {
    return Replace(values: data.dec(_f$values));
  }

  @override
  final Function instantiate = _instantiate;

  static Replace<K, V> fromMap<K, V>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Replace<K, V>>(map);
  }

  static Replace<K, V> fromJson<K, V>(String json) {
    return ensureInitialized().decodeJson<Replace<K, V>>(json);
  }
}

mixin ReplaceMappable<K, V> {
  String toJson() {
    return ReplaceMapper.ensureInitialized().encodeJson<Replace<K, V>>(
      this as Replace<K, V>,
    );
  }

  Map<String, dynamic> toMap() {
    return ReplaceMapper.ensureInitialized().encodeMap<Replace<K, V>>(
      this as Replace<K, V>,
    );
  }

  ReplaceCopyWith<Replace<K, V>, Replace<K, V>, Replace<K, V>, K, V>
  get copyWith => _ReplaceCopyWithImpl<Replace<K, V>, Replace<K, V>, K, V>(
    this as Replace<K, V>,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ReplaceMapper.ensureInitialized().stringifyValue(
      this as Replace<K, V>,
    );
  }

  @override
  bool operator ==(Object other) {
    return ReplaceMapper.ensureInitialized().equalsValue(
      this as Replace<K, V>,
      other,
    );
  }

  @override
  int get hashCode {
    return ReplaceMapper.ensureInitialized().hashValue(this as Replace<K, V>);
  }
}

extension ReplaceValueCopy<$R, $Out, K, V>
    on ObjectCopyWith<$R, Replace<K, V>, $Out> {
  ReplaceCopyWith<$R, Replace<K, V>, $Out, K, V> get $asReplace =>
      $base.as((v, t, t2) => _ReplaceCopyWithImpl<$R, $Out, K, V>(v, t, t2));
}

abstract class ReplaceCopyWith<$R, $In extends Replace<K, V>, $Out, K, V>
    implements PatchCopyWith<$R, $In, $Out, K, V> {
  @override
  $R call({Iterable<_t$_R0<K, V>>? values});
  ReplaceCopyWith<$R2, $In, $Out2, K, V> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ReplaceCopyWithImpl<$R, $Out, K, V>
    extends ClassCopyWithBase<$R, Replace<K, V>, $Out>
    implements ReplaceCopyWith<$R, Replace<K, V>, $Out, K, V> {
  _ReplaceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Replace> $mapper =
      ReplaceMapper.ensureInitialized();
  @override
  $R call({Iterable<_t$_R0<K, V>>? values}) =>
      $apply(FieldCopyWithData({if (values != null) #values: values}));
  @override
  Replace<K, V> $make(CopyWithData data) =>
      Replace(values: data.get(#values, or: $value.values));

  @override
  ReplaceCopyWith<$R2, Replace<K, V>, $Out2, K, V> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ReplaceCopyWithImpl<$R2, $Out2, K, V>($value, $cast, t);
}

class PatchCircuitModelMapper extends ClassMapperBase<PatchCircuitModel> {
  PatchCircuitModelMapper._();

  static PatchCircuitModelMapper? _instance;
  static PatchCircuitModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PatchCircuitModelMapper._());
      PatchMapper.ensureInitialized();
      ComponentModelMapper.ensureInitialized();
      WireModelMapper.ensureInitialized();
      EndpointModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PatchCircuitModel';

  static UuidValue _$id(PatchCircuitModel v) => v.id;
  static const Field<PatchCircuitModel, UuidValue> _f$id = Field('id', _$id);
  static Patch<void, String?>? _$name(PatchCircuitModel v) => v.name;
  static const Field<PatchCircuitModel, Patch<void, String?>> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static Patch<int, ComponentModel>? _$components(PatchCircuitModel v) =>
      v.components;
  static const Field<PatchCircuitModel, Patch<int, ComponentModel>>
  _f$components = Field('components', _$components, opt: true);
  static Patch<int, WireModel>? _$wires(PatchCircuitModel v) => v.wires;
  static const Field<PatchCircuitModel, Patch<int, WireModel>> _f$wires = Field(
    'wires',
    _$wires,
    opt: true,
  );
  static Patch<UuidValue, EndpointModel>? _$endpoints(PatchCircuitModel v) =>
      v.endpoints;
  static const Field<PatchCircuitModel, Patch<UuidValue, EndpointModel>>
  _f$endpoints = Field('endpoints', _$endpoints, opt: true);

  @override
  final MappableFields<PatchCircuitModel> fields = const {
    #id: _f$id,
    #name: _f$name,
    #components: _f$components,
    #wires: _f$wires,
    #endpoints: _f$endpoints,
  };

  static PatchCircuitModel _instantiate(DecodingData data) {
    return PatchCircuitModel(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      components: data.dec(_f$components),
      wires: data.dec(_f$wires),
      endpoints: data.dec(_f$endpoints),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PatchCircuitModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PatchCircuitModel>(map);
  }

  static PatchCircuitModel fromJson(String json) {
    return ensureInitialized().decodeJson<PatchCircuitModel>(json);
  }
}

mixin PatchCircuitModelMappable {
  String toJson() {
    return PatchCircuitModelMapper.ensureInitialized()
        .encodeJson<PatchCircuitModel>(this as PatchCircuitModel);
  }

  Map<String, dynamic> toMap() {
    return PatchCircuitModelMapper.ensureInitialized()
        .encodeMap<PatchCircuitModel>(this as PatchCircuitModel);
  }

  PatchCircuitModelCopyWith<
    PatchCircuitModel,
    PatchCircuitModel,
    PatchCircuitModel
  >
  get copyWith =>
      _PatchCircuitModelCopyWithImpl<PatchCircuitModel, PatchCircuitModel>(
        this as PatchCircuitModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PatchCircuitModelMapper.ensureInitialized().stringifyValue(
      this as PatchCircuitModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return PatchCircuitModelMapper.ensureInitialized().equalsValue(
      this as PatchCircuitModel,
      other,
    );
  }

  @override
  int get hashCode {
    return PatchCircuitModelMapper.ensureInitialized().hashValue(
      this as PatchCircuitModel,
    );
  }
}

extension PatchCircuitModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PatchCircuitModel, $Out> {
  PatchCircuitModelCopyWith<$R, PatchCircuitModel, $Out>
  get $asPatchCircuitModel => $base.as(
    (v, t, t2) => _PatchCircuitModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class PatchCircuitModelCopyWith<
  $R,
  $In extends PatchCircuitModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  PatchCopyWith<$R, Patch<void, String?>, Patch<void, String?>, void, String?>?
  get name;
  PatchCopyWith<
    $R,
    Patch<int, ComponentModel>,
    Patch<int, ComponentModel>,
    int,
    ComponentModel
  >?
  get components;
  PatchCopyWith<
    $R,
    Patch<int, WireModel>,
    Patch<int, WireModel>,
    int,
    WireModel
  >?
  get wires;
  PatchCopyWith<
    $R,
    Patch<UuidValue, EndpointModel>,
    Patch<UuidValue, EndpointModel>,
    UuidValue,
    EndpointModel
  >?
  get endpoints;
  $R call({
    UuidValue? id,
    Patch<void, String?>? name,
    Patch<int, ComponentModel>? components,
    Patch<int, WireModel>? wires,
    Patch<UuidValue, EndpointModel>? endpoints,
  });
  PatchCircuitModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PatchCircuitModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PatchCircuitModel, $Out>
    implements PatchCircuitModelCopyWith<$R, PatchCircuitModel, $Out> {
  _PatchCircuitModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PatchCircuitModel> $mapper =
      PatchCircuitModelMapper.ensureInitialized();
  @override
  PatchCopyWith<$R, Patch<void, String?>, Patch<void, String?>, void, String?>?
  get name => $value.name?.copyWith.$chain((v) => call(name: v));
  @override
  PatchCopyWith<
    $R,
    Patch<int, ComponentModel>,
    Patch<int, ComponentModel>,
    int,
    ComponentModel
  >?
  get components =>
      $value.components?.copyWith.$chain((v) => call(components: v));
  @override
  PatchCopyWith<
    $R,
    Patch<int, WireModel>,
    Patch<int, WireModel>,
    int,
    WireModel
  >?
  get wires => $value.wires?.copyWith.$chain((v) => call(wires: v));
  @override
  PatchCopyWith<
    $R,
    Patch<UuidValue, EndpointModel>,
    Patch<UuidValue, EndpointModel>,
    UuidValue,
    EndpointModel
  >?
  get endpoints => $value.endpoints?.copyWith.$chain((v) => call(endpoints: v));
  @override
  $R call({
    UuidValue? id,
    Object? name = $none,
    Object? components = $none,
    Object? wires = $none,
    Object? endpoints = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != $none) #name: name,
      if (components != $none) #components: components,
      if (wires != $none) #wires: wires,
      if (endpoints != $none) #endpoints: endpoints,
    }),
  );
  @override
  PatchCircuitModel $make(CopyWithData data) => PatchCircuitModel(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    components: data.get(#components, or: $value.components),
    wires: data.get(#wires, or: $value.wires),
    endpoints: data.get(#endpoints, or: $value.endpoints),
  );

  @override
  PatchCircuitModelCopyWith<$R2, PatchCircuitModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PatchCircuitModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CurrentSourceMapper extends SubClassMapperBase<CurrentSource> {
  CurrentSourceMapper._();

  static CurrentSourceMapper? _instance;
  static CurrentSourceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CurrentSourceMapper._());
      BranchModelMapper.ensureInitialized().addSubMapper(_instance!);
      VoltageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CurrentSource';

  static Voltage? _$voltage(CurrentSource v) => v.voltage;
  static const Field<CurrentSource, Voltage> _f$voltage = Field(
    'voltage',
    _$voltage,
    opt: true,
  );

  @override
  final MappableFields<CurrentSource> fields = const {#voltage: _f$voltage};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'currentSource';
  @override
  late final ClassMapperBase superMapper =
      BranchModelMapper.ensureInitialized();

  static CurrentSource _instantiate(DecodingData data) {
    return CurrentSource(voltage: data.dec(_f$voltage));
  }

  @override
  final Function instantiate = _instantiate;

  static CurrentSource fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CurrentSource>(map);
  }

  static CurrentSource fromJson(String json) {
    return ensureInitialized().decodeJson<CurrentSource>(json);
  }
}

mixin CurrentSourceMappable {
  String toJson() {
    return CurrentSourceMapper.ensureInitialized().encodeJson<CurrentSource>(
      this as CurrentSource,
    );
  }

  Map<String, dynamic> toMap() {
    return CurrentSourceMapper.ensureInitialized().encodeMap<CurrentSource>(
      this as CurrentSource,
    );
  }

  CurrentSourceCopyWith<CurrentSource, CurrentSource, CurrentSource>
  get copyWith => _CurrentSourceCopyWithImpl<CurrentSource, CurrentSource>(
    this as CurrentSource,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CurrentSourceMapper.ensureInitialized().stringifyValue(
      this as CurrentSource,
    );
  }

  @override
  bool operator ==(Object other) {
    return CurrentSourceMapper.ensureInitialized().equalsValue(
      this as CurrentSource,
      other,
    );
  }

  @override
  int get hashCode {
    return CurrentSourceMapper.ensureInitialized().hashValue(
      this as CurrentSource,
    );
  }
}

extension CurrentSourceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CurrentSource, $Out> {
  CurrentSourceCopyWith<$R, CurrentSource, $Out> get $asCurrentSource =>
      $base.as((v, t, t2) => _CurrentSourceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CurrentSourceCopyWith<$R, $In extends CurrentSource, $Out>
    implements BranchModelCopyWith<$R, $In, $Out> {
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage;
  @override
  $R call({Voltage? voltage});
  CurrentSourceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CurrentSourceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CurrentSource, $Out>
    implements CurrentSourceCopyWith<$R, CurrentSource, $Out> {
  _CurrentSourceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CurrentSource> $mapper =
      CurrentSourceMapper.ensureInitialized();
  @override
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage =>
      $value.voltage?.copyWith.$chain((v) => call(voltage: v));
  @override
  $R call({Object? voltage = $none}) =>
      $apply(FieldCopyWithData({if (voltage != $none) #voltage: voltage}));
  @override
  CurrentSource $make(CopyWithData data) =>
      CurrentSource(voltage: data.get(#voltage, or: $value.voltage));

  @override
  CurrentSourceCopyWith<$R2, CurrentSource, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CurrentSourceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IdealDiodeMapper extends SubClassMapperBase<IdealDiode> {
  IdealDiodeMapper._();

  static IdealDiodeMapper? _instance;
  static IdealDiodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IdealDiodeMapper._());
      BranchModelMapper.ensureInitialized().addSubMapper(_instance!);
      VoltageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'IdealDiode';

  static Voltage? _$voltage(IdealDiode v) => v.voltage;
  static const Field<IdealDiode, Voltage> _f$voltage = Field(
    'voltage',
    _$voltage,
    opt: true,
  );

  @override
  final MappableFields<IdealDiode> fields = const {#voltage: _f$voltage};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'idealDiode';
  @override
  late final ClassMapperBase superMapper =
      BranchModelMapper.ensureInitialized();

  static IdealDiode _instantiate(DecodingData data) {
    return IdealDiode(voltage: data.dec(_f$voltage));
  }

  @override
  final Function instantiate = _instantiate;

  static IdealDiode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IdealDiode>(map);
  }

  static IdealDiode fromJson(String json) {
    return ensureInitialized().decodeJson<IdealDiode>(json);
  }
}

mixin IdealDiodeMappable {
  String toJson() {
    return IdealDiodeMapper.ensureInitialized().encodeJson<IdealDiode>(
      this as IdealDiode,
    );
  }

  Map<String, dynamic> toMap() {
    return IdealDiodeMapper.ensureInitialized().encodeMap<IdealDiode>(
      this as IdealDiode,
    );
  }

  IdealDiodeCopyWith<IdealDiode, IdealDiode, IdealDiode> get copyWith =>
      _IdealDiodeCopyWithImpl<IdealDiode, IdealDiode>(
        this as IdealDiode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IdealDiodeMapper.ensureInitialized().stringifyValue(
      this as IdealDiode,
    );
  }

  @override
  bool operator ==(Object other) {
    return IdealDiodeMapper.ensureInitialized().equalsValue(
      this as IdealDiode,
      other,
    );
  }

  @override
  int get hashCode {
    return IdealDiodeMapper.ensureInitialized().hashValue(this as IdealDiode);
  }
}

extension IdealDiodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IdealDiode, $Out> {
  IdealDiodeCopyWith<$R, IdealDiode, $Out> get $asIdealDiode =>
      $base.as((v, t, t2) => _IdealDiodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IdealDiodeCopyWith<$R, $In extends IdealDiode, $Out>
    implements BranchModelCopyWith<$R, $In, $Out> {
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage;
  @override
  $R call({Voltage? voltage});
  IdealDiodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IdealDiodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IdealDiode, $Out>
    implements IdealDiodeCopyWith<$R, IdealDiode, $Out> {
  _IdealDiodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IdealDiode> $mapper =
      IdealDiodeMapper.ensureInitialized();
  @override
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage =>
      $value.voltage?.copyWith.$chain((v) => call(voltage: v));
  @override
  $R call({Object? voltage = $none}) =>
      $apply(FieldCopyWithData({if (voltage != $none) #voltage: voltage}));
  @override
  IdealDiode $make(CopyWithData data) =>
      IdealDiode(voltage: data.get(#voltage, or: $value.voltage));

  @override
  IdealDiodeCopyWith<$R2, IdealDiode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IdealDiodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ResistorMapper extends SubClassMapperBase<Resistor> {
  ResistorMapper._();

  static ResistorMapper? _instance;
  static ResistorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ResistorMapper._());
      BranchModelMapper.ensureInitialized().addSubMapper(_instance!);
      ResistanceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Resistor';

  static Resistance? _$resistance(Resistor v) => v.resistance;
  static const Field<Resistor, Resistance> _f$resistance = Field(
    'resistance',
    _$resistance,
    opt: true,
  );

  @override
  final MappableFields<Resistor> fields = const {#resistance: _f$resistance};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'resistor';
  @override
  late final ClassMapperBase superMapper =
      BranchModelMapper.ensureInitialized();

  static Resistor _instantiate(DecodingData data) {
    return Resistor(resistance: data.dec(_f$resistance));
  }

  @override
  final Function instantiate = _instantiate;

  static Resistor fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Resistor>(map);
  }

  static Resistor fromJson(String json) {
    return ensureInitialized().decodeJson<Resistor>(json);
  }
}

mixin ResistorMappable {
  String toJson() {
    return ResistorMapper.ensureInitialized().encodeJson<Resistor>(
      this as Resistor,
    );
  }

  Map<String, dynamic> toMap() {
    return ResistorMapper.ensureInitialized().encodeMap<Resistor>(
      this as Resistor,
    );
  }

  ResistorCopyWith<Resistor, Resistor, Resistor> get copyWith =>
      _ResistorCopyWithImpl<Resistor, Resistor>(
        this as Resistor,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ResistorMapper.ensureInitialized().stringifyValue(this as Resistor);
  }

  @override
  bool operator ==(Object other) {
    return ResistorMapper.ensureInitialized().equalsValue(
      this as Resistor,
      other,
    );
  }

  @override
  int get hashCode {
    return ResistorMapper.ensureInitialized().hashValue(this as Resistor);
  }
}

extension ResistorValueCopy<$R, $Out> on ObjectCopyWith<$R, Resistor, $Out> {
  ResistorCopyWith<$R, Resistor, $Out> get $asResistor =>
      $base.as((v, t, t2) => _ResistorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ResistorCopyWith<$R, $In extends Resistor, $Out>
    implements BranchModelCopyWith<$R, $In, $Out> {
  ResistanceCopyWith<$R, Resistance, Resistance>? get resistance;
  @override
  $R call({Resistance? resistance});
  ResistorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ResistorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Resistor, $Out>
    implements ResistorCopyWith<$R, Resistor, $Out> {
  _ResistorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Resistor> $mapper =
      ResistorMapper.ensureInitialized();
  @override
  ResistanceCopyWith<$R, Resistance, Resistance>? get resistance =>
      $value.resistance?.copyWith.$chain((v) => call(resistance: v));
  @override
  $R call({Object? resistance = $none}) => $apply(
    FieldCopyWithData({if (resistance != $none) #resistance: resistance}),
  );
  @override
  Resistor $make(CopyWithData data) =>
      Resistor(resistance: data.get(#resistance, or: $value.resistance));

  @override
  ResistorCopyWith<$R2, Resistor, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ResistorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ResistanceMapper extends ClassMapperBase<Resistance> {
  ResistanceMapper._();

  static ResistanceMapper? _instance;
  static ResistanceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ResistanceMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Resistance';

  static double _$ohms(Resistance v) => v.ohms;
  static const Field<Resistance, double> _f$ohms = Field('ohms', _$ohms);

  @override
  final MappableFields<Resistance> fields = const {#ohms: _f$ohms};

  static Resistance _instantiate(DecodingData data) {
    return Resistance(ohms: data.dec(_f$ohms));
  }

  @override
  final Function instantiate = _instantiate;

  static Resistance fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Resistance>(map);
  }

  static Resistance fromJson(String json) {
    return ensureInitialized().decodeJson<Resistance>(json);
  }
}

mixin ResistanceMappable {
  String toJson() {
    return ResistanceMapper.ensureInitialized().encodeJson<Resistance>(
      this as Resistance,
    );
  }

  Map<String, dynamic> toMap() {
    return ResistanceMapper.ensureInitialized().encodeMap<Resistance>(
      this as Resistance,
    );
  }

  ResistanceCopyWith<Resistance, Resistance, Resistance> get copyWith =>
      _ResistanceCopyWithImpl<Resistance, Resistance>(
        this as Resistance,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ResistanceMapper.ensureInitialized().stringifyValue(
      this as Resistance,
    );
  }

  @override
  bool operator ==(Object other) {
    return ResistanceMapper.ensureInitialized().equalsValue(
      this as Resistance,
      other,
    );
  }

  @override
  int get hashCode {
    return ResistanceMapper.ensureInitialized().hashValue(this as Resistance);
  }
}

extension ResistanceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Resistance, $Out> {
  ResistanceCopyWith<$R, Resistance, $Out> get $asResistance =>
      $base.as((v, t, t2) => _ResistanceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ResistanceCopyWith<$R, $In extends Resistance, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? ohms});
  ResistanceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ResistanceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Resistance, $Out>
    implements ResistanceCopyWith<$R, Resistance, $Out> {
  _ResistanceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Resistance> $mapper =
      ResistanceMapper.ensureInitialized();
  @override
  $R call({double? ohms}) =>
      $apply(FieldCopyWithData({if (ohms != null) #ohms: ohms}));
  @override
  Resistance $make(CopyWithData data) =>
      Resistance(ohms: data.get(#ohms, or: $value.ohms));

  @override
  ResistanceCopyWith<$R2, Resistance, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ResistanceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RealDiodeMapper extends SubClassMapperBase<RealDiode> {
  RealDiodeMapper._();

  static RealDiodeMapper? _instance;
  static RealDiodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RealDiodeMapper._());
      BranchModelMapper.ensureInitialized().addSubMapper(_instance!);
      CurrentMapper.ensureInitialized();
      VoltageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RealDiode';

  static Current? _$i0(RealDiode v) => v.i0;
  static const Field<RealDiode, Current> _f$i0 = Field('i0', _$i0, opt: true);
  static Voltage? _$vt(RealDiode v) => v.vt;
  static const Field<RealDiode, Voltage> _f$vt = Field('vt', _$vt, opt: true);
  static double? _$n(RealDiode v) => v.n;
  static const Field<RealDiode, double> _f$n = Field('n', _$n, opt: true);

  @override
  final MappableFields<RealDiode> fields = const {
    #i0: _f$i0,
    #vt: _f$vt,
    #n: _f$n,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'realDiode';
  @override
  late final ClassMapperBase superMapper =
      BranchModelMapper.ensureInitialized();

  static RealDiode _instantiate(DecodingData data) {
    return RealDiode(
      i0: data.dec(_f$i0),
      vt: data.dec(_f$vt),
      n: data.dec(_f$n),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RealDiode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RealDiode>(map);
  }

  static RealDiode fromJson(String json) {
    return ensureInitialized().decodeJson<RealDiode>(json);
  }
}

mixin RealDiodeMappable {
  String toJson() {
    return RealDiodeMapper.ensureInitialized().encodeJson<RealDiode>(
      this as RealDiode,
    );
  }

  Map<String, dynamic> toMap() {
    return RealDiodeMapper.ensureInitialized().encodeMap<RealDiode>(
      this as RealDiode,
    );
  }

  RealDiodeCopyWith<RealDiode, RealDiode, RealDiode> get copyWith =>
      _RealDiodeCopyWithImpl<RealDiode, RealDiode>(
        this as RealDiode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RealDiodeMapper.ensureInitialized().stringifyValue(
      this as RealDiode,
    );
  }

  @override
  bool operator ==(Object other) {
    return RealDiodeMapper.ensureInitialized().equalsValue(
      this as RealDiode,
      other,
    );
  }

  @override
  int get hashCode {
    return RealDiodeMapper.ensureInitialized().hashValue(this as RealDiode);
  }
}

extension RealDiodeValueCopy<$R, $Out> on ObjectCopyWith<$R, RealDiode, $Out> {
  RealDiodeCopyWith<$R, RealDiode, $Out> get $asRealDiode =>
      $base.as((v, t, t2) => _RealDiodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RealDiodeCopyWith<$R, $In extends RealDiode, $Out>
    implements BranchModelCopyWith<$R, $In, $Out> {
  CurrentCopyWith<$R, Current, Current>? get i0;
  VoltageCopyWith<$R, Voltage, Voltage>? get vt;
  @override
  $R call({Current? i0, Voltage? vt, double? n});
  RealDiodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RealDiodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RealDiode, $Out>
    implements RealDiodeCopyWith<$R, RealDiode, $Out> {
  _RealDiodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RealDiode> $mapper =
      RealDiodeMapper.ensureInitialized();
  @override
  CurrentCopyWith<$R, Current, Current>? get i0 =>
      $value.i0?.copyWith.$chain((v) => call(i0: v));
  @override
  VoltageCopyWith<$R, Voltage, Voltage>? get vt =>
      $value.vt?.copyWith.$chain((v) => call(vt: v));
  @override
  $R call({Object? i0 = $none, Object? vt = $none, Object? n = $none}) =>
      $apply(
        FieldCopyWithData({
          if (i0 != $none) #i0: i0,
          if (vt != $none) #vt: vt,
          if (n != $none) #n: n,
        }),
      );
  @override
  RealDiode $make(CopyWithData data) => RealDiode(
    i0: data.get(#i0, or: $value.i0),
    vt: data.get(#vt, or: $value.vt),
    n: data.get(#n, or: $value.n),
  );

  @override
  RealDiodeCopyWith<$R2, RealDiode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RealDiodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VoltageSourceMapper extends SubClassMapperBase<VoltageSource> {
  VoltageSourceMapper._();

  static VoltageSourceMapper? _instance;
  static VoltageSourceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VoltageSourceMapper._());
      BranchModelMapper.ensureInitialized().addSubMapper(_instance!);
      VoltageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VoltageSource';

  static Voltage? _$voltage(VoltageSource v) => v.voltage;
  static const Field<VoltageSource, Voltage> _f$voltage = Field(
    'voltage',
    _$voltage,
    opt: true,
  );

  @override
  final MappableFields<VoltageSource> fields = const {#voltage: _f$voltage};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'voltageSource';
  @override
  late final ClassMapperBase superMapper =
      BranchModelMapper.ensureInitialized();

  static VoltageSource _instantiate(DecodingData data) {
    return VoltageSource(voltage: data.dec(_f$voltage));
  }

  @override
  final Function instantiate = _instantiate;

  static VoltageSource fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VoltageSource>(map);
  }

  static VoltageSource fromJson(String json) {
    return ensureInitialized().decodeJson<VoltageSource>(json);
  }
}

mixin VoltageSourceMappable {
  String toJson() {
    return VoltageSourceMapper.ensureInitialized().encodeJson<VoltageSource>(
      this as VoltageSource,
    );
  }

  Map<String, dynamic> toMap() {
    return VoltageSourceMapper.ensureInitialized().encodeMap<VoltageSource>(
      this as VoltageSource,
    );
  }

  VoltageSourceCopyWith<VoltageSource, VoltageSource, VoltageSource>
  get copyWith => _VoltageSourceCopyWithImpl<VoltageSource, VoltageSource>(
    this as VoltageSource,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return VoltageSourceMapper.ensureInitialized().stringifyValue(
      this as VoltageSource,
    );
  }

  @override
  bool operator ==(Object other) {
    return VoltageSourceMapper.ensureInitialized().equalsValue(
      this as VoltageSource,
      other,
    );
  }

  @override
  int get hashCode {
    return VoltageSourceMapper.ensureInitialized().hashValue(
      this as VoltageSource,
    );
  }
}

extension VoltageSourceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VoltageSource, $Out> {
  VoltageSourceCopyWith<$R, VoltageSource, $Out> get $asVoltageSource =>
      $base.as((v, t, t2) => _VoltageSourceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VoltageSourceCopyWith<$R, $In extends VoltageSource, $Out>
    implements BranchModelCopyWith<$R, $In, $Out> {
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage;
  @override
  $R call({Voltage? voltage});
  VoltageSourceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VoltageSourceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VoltageSource, $Out>
    implements VoltageSourceCopyWith<$R, VoltageSource, $Out> {
  _VoltageSourceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VoltageSource> $mapper =
      VoltageSourceMapper.ensureInitialized();
  @override
  VoltageCopyWith<$R, Voltage, Voltage>? get voltage =>
      $value.voltage?.copyWith.$chain((v) => call(voltage: v));
  @override
  $R call({Object? voltage = $none}) =>
      $apply(FieldCopyWithData({if (voltage != $none) #voltage: voltage}));
  @override
  VoltageSource $make(CopyWithData data) =>
      VoltageSource(voltage: data.get(#voltage, or: $value.voltage));

  @override
  VoltageSourceCopyWith<$R2, VoltageSource, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VoltageSourceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ZenerDiodeMapper extends SubClassMapperBase<ZenerDiode> {
  ZenerDiodeMapper._();

  static ZenerDiodeMapper? _instance;
  static ZenerDiodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZenerDiodeMapper._());
      BranchModelMapper.ensureInitialized().addSubMapper(_instance!);
      VoltageMapper.ensureInitialized();
      ResistanceMapper.ensureInitialized();
      CurrentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ZenerDiode';

  static Voltage? _$vzt(ZenerDiode v) => v.vzt;
  static const Field<ZenerDiode, Voltage> _f$vzt = Field(
    'vzt',
    _$vzt,
    opt: true,
  );
  static Resistance? _$rzt(ZenerDiode v) => v.rzt;
  static const Field<ZenerDiode, Resistance> _f$rzt = Field(
    'rzt',
    _$rzt,
    opt: true,
  );
  static Current? _$izt(ZenerDiode v) => v.izt;
  static const Field<ZenerDiode, Current> _f$izt = Field(
    'izt',
    _$izt,
    opt: true,
  );

  @override
  final MappableFields<ZenerDiode> fields = const {
    #vzt: _f$vzt,
    #rzt: _f$rzt,
    #izt: _f$izt,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'zenerDiode';
  @override
  late final ClassMapperBase superMapper =
      BranchModelMapper.ensureInitialized();

  static ZenerDiode _instantiate(DecodingData data) {
    return ZenerDiode(
      vzt: data.dec(_f$vzt),
      rzt: data.dec(_f$rzt),
      izt: data.dec(_f$izt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ZenerDiode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ZenerDiode>(map);
  }

  static ZenerDiode fromJson(String json) {
    return ensureInitialized().decodeJson<ZenerDiode>(json);
  }
}

mixin ZenerDiodeMappable {
  String toJson() {
    return ZenerDiodeMapper.ensureInitialized().encodeJson<ZenerDiode>(
      this as ZenerDiode,
    );
  }

  Map<String, dynamic> toMap() {
    return ZenerDiodeMapper.ensureInitialized().encodeMap<ZenerDiode>(
      this as ZenerDiode,
    );
  }

  ZenerDiodeCopyWith<ZenerDiode, ZenerDiode, ZenerDiode> get copyWith =>
      _ZenerDiodeCopyWithImpl<ZenerDiode, ZenerDiode>(
        this as ZenerDiode,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ZenerDiodeMapper.ensureInitialized().stringifyValue(
      this as ZenerDiode,
    );
  }

  @override
  bool operator ==(Object other) {
    return ZenerDiodeMapper.ensureInitialized().equalsValue(
      this as ZenerDiode,
      other,
    );
  }

  @override
  int get hashCode {
    return ZenerDiodeMapper.ensureInitialized().hashValue(this as ZenerDiode);
  }
}

extension ZenerDiodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ZenerDiode, $Out> {
  ZenerDiodeCopyWith<$R, ZenerDiode, $Out> get $asZenerDiode =>
      $base.as((v, t, t2) => _ZenerDiodeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ZenerDiodeCopyWith<$R, $In extends ZenerDiode, $Out>
    implements BranchModelCopyWith<$R, $In, $Out> {
  VoltageCopyWith<$R, Voltage, Voltage>? get vzt;
  ResistanceCopyWith<$R, Resistance, Resistance>? get rzt;
  CurrentCopyWith<$R, Current, Current>? get izt;
  @override
  $R call({Voltage? vzt, Resistance? rzt, Current? izt});
  ZenerDiodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ZenerDiodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ZenerDiode, $Out>
    implements ZenerDiodeCopyWith<$R, ZenerDiode, $Out> {
  _ZenerDiodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ZenerDiode> $mapper =
      ZenerDiodeMapper.ensureInitialized();
  @override
  VoltageCopyWith<$R, Voltage, Voltage>? get vzt =>
      $value.vzt?.copyWith.$chain((v) => call(vzt: v));
  @override
  ResistanceCopyWith<$R, Resistance, Resistance>? get rzt =>
      $value.rzt?.copyWith.$chain((v) => call(rzt: v));
  @override
  CurrentCopyWith<$R, Current, Current>? get izt =>
      $value.izt?.copyWith.$chain((v) => call(izt: v));
  @override
  $R call({Object? vzt = $none, Object? rzt = $none, Object? izt = $none}) =>
      $apply(
        FieldCopyWithData({
          if (vzt != $none) #vzt: vzt,
          if (rzt != $none) #rzt: rzt,
          if (izt != $none) #izt: izt,
        }),
      );
  @override
  ZenerDiode $make(CopyWithData data) => ZenerDiode(
    vzt: data.get(#vzt, or: $value.vzt),
    rzt: data.get(#rzt, or: $value.rzt),
    izt: data.get(#izt, or: $value.izt),
  );

  @override
  ZenerDiodeCopyWith<$R2, ZenerDiode, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ZenerDiodeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

typedef _t$_R0<A, B> = (A, B);

class _t$_R0Mapper extends RecordMapperBase<_t$_R0> {
  static _t$_R0Mapper? _instance;
  _t$_R0Mapper._();

  static _t$_R0Mapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = _t$_R0Mapper._());
      MapperBase.addType(<A, B>(f) => f<(A, B)>());
    }
    return _instance!;
  }

  static dynamic _$$1(_t$_R0 v) => v.$1;
  static dynamic _arg$$1<A, B>(f) => f<A>();
  static const Field<_t$_R0, dynamic> _f$$1 = Field('\$1', _$$1, arg: _arg$$1);
  static dynamic _$$2(_t$_R0 v) => v.$2;
  static dynamic _arg$$2<A, B>(f) => f<B>();
  static const Field<_t$_R0, dynamic> _f$$2 = Field('\$2', _$$2, arg: _arg$$2);

  @override
  final MappableFields<_t$_R0> fields = const {#$1: _f$$1, #$2: _f$$2};

  @override
  Function get typeFactory =>
      <A, B>(f) => f<_t$_R0<A, B>>();

  static _t$_R0<A, B> _instantiate<A, B>(DecodingData<_t$_R0> data) {
    return (data.dec(_f$$1), data.dec(_f$$2));
  }

  @override
  final Function instantiate = _instantiate;

  static _t$_R0<A, B> fromMap<A, B>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<_t$_R0<A, B>>(map);
  }

  static _t$_R0<A, B> fromJson<A, B>(String json) {
    return ensureInitialized().decodeJson<_t$_R0<A, B>>(json);
  }
}

