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

