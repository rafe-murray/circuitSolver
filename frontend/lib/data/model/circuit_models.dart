import 'package:frontend/utils/json.dart';
import 'package:uuid/uuid_value.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:ui';

part 'circuit_models.freezed.dart';
part 'circuit_models.g.dart';

@freezed
abstract class CircuitModel with _$CircuitModel {
  const factory CircuitModel({
    @UuidValueConverter() required UuidValue id,
    String? name,
    required List<ComponentModel> components,
    required List<WireModel> wires,
  }) = _CircuitModel;

  factory CircuitModel.fromJson(Map<String, dynamic> json) =>
      _$CircuitModelFromJson(json);
}

@freezed
abstract class WireModel with _$WireModel {
  const factory WireModel({
    @UuidValueConverter() required UuidValue id,
    // not named from and to since not meaningful in this context
    required EndpointModel endpoint1,
    required EndpointModel endpoint2,
  }) = _WireModel;
  factory WireModel.fromJson(Map<String, dynamic> json) =>
      _$WireModelFromJson(json);
}

@freezed
abstract class ComponentModel with _$ComponentModel {
  const factory ComponentModel({
    @UuidValueConverter() required UuidValue id,
    required EndpointModel from,
    required EndpointModel to,
    required BranchModel branch,
    Current? current,
  }) = _ComponentModel;

  factory ComponentModel.fromJson(Map<String, dynamic> json) =>
      _$ComponentModelFromJson(json);
}

@freezed
abstract class EndpointModel with _$EndpointModel {
  const factory EndpointModel({
    @OffsetConverter() required Offset pos,
    @UuidValueConverter() required UuidValue id,
    Voltage? voltage,
  }) = _EndpointModel;

  factory EndpointModel.fromJson(Map<String, dynamic> json) =>
      _$EndpointModelFromJson(json);
}

@freezed
sealed class BranchModel with _$BranchModel {
  // TODO: should these be private classes?
  const factory BranchModel.currentSource({Voltage? voltage}) = CurrentSource;
  const factory BranchModel.idealDiode({Voltage? voltage}) = IdealDiode;
  const factory BranchModel.realDiode({Current? i0, Voltage? vt, double? n}) =
      RealDiode;
  const factory BranchModel.resistor({Resistance? resistance}) = Resistor;
  const factory BranchModel.voltageSource({Voltage? voltage}) = VoltageSource;
  const factory BranchModel.zenerDiode({
    Voltage? vzt,
    Resistance? rzt,
    Current? izt,
  }) = ZenerDiode;
  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);
}

@freezed
abstract class Resistance with _$Resistance {
  const Resistance._();
  const factory Resistance({required double ohms}) = _Resistance;
  double get milliOhms => ohms * 1000;
  double get kiloOhms => ohms / 1000;
  factory Resistance.fromJson(Map<String, dynamic> json) =>
      _$ResistanceFromJson(json);
}

@freezed
abstract class Voltage with _$Voltage {
  const Voltage._();
  const factory Voltage({required double v}) = _Voltage;
  double get volts => v;
  double get milliVolts => v * 1000;
  factory Voltage.fromJson(Map<String, dynamic> json) =>
      _$VoltageFromJson(json);
}

@freezed
abstract class Current with _$Current {
  const Current._();
  const factory Current({required double a}) = _Current;
  double get amps => a;
  double get milliAmps => a * 1000;
  factory Current.fromJson(Map<String, dynamic> json) =>
      _$CurrentFromJson(json);
}
