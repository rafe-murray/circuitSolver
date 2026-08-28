import 'package:dart_mappable/dart_mappable.dart';
import 'package:frontend/utils/json.dart';
import 'package:uuid/uuid_value.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:ui';

part 'circuit_models.freezed.dart';
part 'circuit_models.g.dart';
part 'circuit_models.mapper.dart';

// TODO: use a separate List<EndpointModel> for the endpoints.
//
// This will allow us to reference them by id only in the components and wires,
// and thus make updates to endpoints easy - which is important for UI responsiveness

@MappableClass()
class CircuitModel with CircuitModelMappable {
  final UuidValue id;
  final String? name;
  final List<ComponentModel> components;
  final List<WireModel> wires;
  final Map<UuidValue, EndpointModel> endpoints;
  const CircuitModel({
    required this.id,
    required this.name,
    required this.components,
    required this.wires,
    required this.endpoints,
  });
}

@MappableClass(discriminatorKey: 'type')
sealed class Patch<K, V> with PatchMappable<K, V> {
  @MappableConstructor()
  const Patch._();

  // const factory Patch.add({required Iterable<(K, V)> value}) = Add<K, V>;
  // const factory Patch.remove({required K position}) = Remove<K, V>;
  // const factory Patch.change({required K position, required V value}) =
  //     Change<K, V>;
  // const factory Patch.replace({required Iterable<(K, V)> values}) =
  //     Replace<K, V>;
}

@MappableClass(discriminatorValue: 'add')
class Add<K, V> extends Patch<K, V> with AddMappable<K, V> {
  final Iterable<(K, V)> value;
  const Add({required this.value}) : super._();
}

@MappableClass(discriminatorValue: 'remove')
class Remove<K, V> extends Patch<K, V> with RemoveMappable<K, V> {
  final K position;
  const Remove({required this.position}) : super._();
}

@MappableClass(discriminatorValue: 'change')
class Change<K, V> extends Patch<K, V> with ChangeMappable<K, V> {
  final K position;
  final V value;
  const Change({required this.position, required this.value}) : super._();
}

@MappableClass(discriminatorValue: 'replace')
class Replace<K, V> extends Patch<K, V> with ReplaceMappable<K, V> {
  final Iterable<(K, V)> values;
  const Replace({required this.values}) : super._();
}

@MappableClass()
class PatchCircuitModel with PatchCircuitModelMappable {
  final UuidValue id;
  final Patch<void, String?>? name;
  final Patch<int, ComponentModel>? components;
  final Patch<int, WireModel>? wires;
  final Patch<UuidValue, EndpointModel>? endpoints;
  const PatchCircuitModel({
    required this.id,
    this.name,
    this.components,
    this.wires,
    this.endpoints,
  });
}

@MappableClass()
class WireModel with WireModelMappable {
  final UuidValue id;
  // not named from and to since not meaningful in this context
  final UuidValue endpoint1Id;
  final UuidValue endpoint2Id;

  const WireModel({
    required this.id,
    required this.endpoint1Id,
    required this.endpoint2Id,
  });
}

@MappableClass()
class ComponentModel with ComponentModelMappable {
  final UuidValue id;
  final UuidValue fromId;
  final UuidValue toId;
  final BranchModel branch;
  final Current? current;

  const ComponentModel({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.branch,
    this.current,
  });
}

@MappableClass()
class EndpointModel with EndpointModelMappable {
  final Offset pos;
  final UuidValue id;
  final Voltage? voltage;
  const EndpointModel({required this.pos, required this.id, this.voltage});
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
  const factory Voltage({required double volts}) = _Voltage;
  double get milliVolts => volts * 1000;
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
