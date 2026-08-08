// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CircuitModel _$CircuitModelFromJson(Map<String, dynamic> json) =>
    _CircuitModel(
      id: const UuidValueConverter().fromJson(json['id'] as String),
      name: json['name'] as String?,
      components: (json['components'] as List<dynamic>)
          .map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      wires: (json['wires'] as List<dynamic>)
          .map((e) => WireModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CircuitModelToJson(_CircuitModel instance) =>
    <String, dynamic>{
      'id': const UuidValueConverter().toJson(instance.id),
      'name': instance.name,
      'components': instance.components,
      'wires': instance.wires,
    };

_WireModel _$WireModelFromJson(Map<String, dynamic> json) => _WireModel(
  id: const UuidValueConverter().fromJson(json['id'] as String),
  endpoint1: EndpointModel.fromJson(json['endpoint1'] as Map<String, dynamic>),
  endpoint2: EndpointModel.fromJson(json['endpoint2'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WireModelToJson(_WireModel instance) =>
    <String, dynamic>{
      'id': const UuidValueConverter().toJson(instance.id),
      'endpoint1': instance.endpoint1,
      'endpoint2': instance.endpoint2,
    };

_ComponentModel _$ComponentModelFromJson(Map<String, dynamic> json) =>
    _ComponentModel(
      id: const UuidValueConverter().fromJson(json['id'] as String),
      from: EndpointModel.fromJson(json['from'] as Map<String, dynamic>),
      to: EndpointModel.fromJson(json['to'] as Map<String, dynamic>),
      branch: BranchModel.fromJson(json['branch'] as Map<String, dynamic>),
      current: json['current'] == null
          ? null
          : Current.fromJson(json['current'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComponentModelToJson(_ComponentModel instance) =>
    <String, dynamic>{
      'id': const UuidValueConverter().toJson(instance.id),
      'from': instance.from,
      'to': instance.to,
      'branch': instance.branch,
      'current': instance.current,
    };

_EndpointModel _$EndpointModelFromJson(Map<String, dynamic> json) =>
    _EndpointModel(
      pos: const OffsetConverter().fromJson(
        json['pos'] as Map<String, dynamic>,
      ),
      id: const UuidValueConverter().fromJson(json['id'] as String),
      voltage: json['voltage'] == null
          ? null
          : Voltage.fromJson(json['voltage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EndpointModelToJson(_EndpointModel instance) =>
    <String, dynamic>{
      'pos': const OffsetConverter().toJson(instance.pos),
      'id': const UuidValueConverter().toJson(instance.id),
      'voltage': instance.voltage,
    };

CurrentSource _$CurrentSourceFromJson(Map<String, dynamic> json) =>
    CurrentSource(
      voltage: json['voltage'] == null
          ? null
          : Voltage.fromJson(json['voltage'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CurrentSourceToJson(CurrentSource instance) =>
    <String, dynamic>{
      'voltage': instance.voltage,
      'runtimeType': instance.$type,
    };

IdealDiode _$IdealDiodeFromJson(Map<String, dynamic> json) => IdealDiode(
  voltage: json['voltage'] == null
      ? null
      : Voltage.fromJson(json['voltage'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$IdealDiodeToJson(IdealDiode instance) =>
    <String, dynamic>{
      'voltage': instance.voltage,
      'runtimeType': instance.$type,
    };

RealDiode _$RealDiodeFromJson(Map<String, dynamic> json) => RealDiode(
  i0: json['i0'] == null
      ? null
      : Current.fromJson(json['i0'] as Map<String, dynamic>),
  vt: json['vt'] == null
      ? null
      : Voltage.fromJson(json['vt'] as Map<String, dynamic>),
  n: (json['n'] as num?)?.toDouble(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$RealDiodeToJson(RealDiode instance) => <String, dynamic>{
  'i0': instance.i0,
  'vt': instance.vt,
  'n': instance.n,
  'runtimeType': instance.$type,
};

Resistor _$ResistorFromJson(Map<String, dynamic> json) => Resistor(
  resistance: json['resistance'] == null
      ? null
      : Resistance.fromJson(json['resistance'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ResistorToJson(Resistor instance) => <String, dynamic>{
  'resistance': instance.resistance,
  'runtimeType': instance.$type,
};

VoltageSource _$VoltageSourceFromJson(Map<String, dynamic> json) =>
    VoltageSource(
      voltage: json['voltage'] == null
          ? null
          : Voltage.fromJson(json['voltage'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$VoltageSourceToJson(VoltageSource instance) =>
    <String, dynamic>{
      'voltage': instance.voltage,
      'runtimeType': instance.$type,
    };

ZenerDiode _$ZenerDiodeFromJson(Map<String, dynamic> json) => ZenerDiode(
  vzt: json['vzt'] == null
      ? null
      : Voltage.fromJson(json['vzt'] as Map<String, dynamic>),
  rzt: json['rzt'] == null
      ? null
      : Resistance.fromJson(json['rzt'] as Map<String, dynamic>),
  izt: json['izt'] == null
      ? null
      : Current.fromJson(json['izt'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ZenerDiodeToJson(ZenerDiode instance) =>
    <String, dynamic>{
      'vzt': instance.vzt,
      'rzt': instance.rzt,
      'izt': instance.izt,
      'runtimeType': instance.$type,
    };

_Resistance _$ResistanceFromJson(Map<String, dynamic> json) =>
    _Resistance(ohms: (json['ohms'] as num).toDouble());

Map<String, dynamic> _$ResistanceToJson(_Resistance instance) =>
    <String, dynamic>{'ohms': instance.ohms};

_Voltage _$VoltageFromJson(Map<String, dynamic> json) =>
    _Voltage(v: (json['v'] as num).toDouble());

Map<String, dynamic> _$VoltageToJson(_Voltage instance) => <String, dynamic>{
  'v': instance.v,
};

_Current _$CurrentFromJson(Map<String, dynamic> json) =>
    _Current(a: (json['a'] as num).toDouble());

Map<String, dynamic> _$CurrentToJson(_Current instance) => <String, dynamic>{
  'a': instance.a,
};
