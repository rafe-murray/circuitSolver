// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
    _Voltage(volts: (json['volts'] as num).toDouble());

Map<String, dynamic> _$VoltageToJson(_Voltage instance) => <String, dynamic>{
  'volts': instance.volts,
};

_Current _$CurrentFromJson(Map<String, dynamic> json) =>
    _Current(a: (json['a'] as num).toDouble());

Map<String, dynamic> _$CurrentToJson(_Current instance) => <String, dynamic>{
  'a': instance.a,
};
