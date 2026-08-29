import 'package:dart_mappable/dart_mappable.dart';
import 'package:frontend/utils/json.dart';
import 'package:uuid/uuid_value.dart';
import 'dart:ui';

part 'circuit_models.mapper.dart';

// TODO: use a separate List<EndpointModel> for the endpoints.
//
// This will allow us to reference them by id only in the components and wires,
// and thus make updates to endpoints easy - which is important for UI responsiveness

@MappableClass(includeCustomMappers: [UuidValueMapper()])
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
  final String? name;
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

@MappableClass(includeCustomMappers: [OffsetMapper()])
class EndpointModel with EndpointModelMappable {
  final Offset pos;
  final UuidValue id;
  final Voltage? voltage;
  const EndpointModel({required this.pos, required this.id, this.voltage});
}

@MappableClass(discriminatorKey: 'type')
sealed class BranchModel with BranchModelMappable {
  const BranchModel._();
}

@MappableClass(discriminatorValue: 'currentSource')
class CurrentSource extends BranchModel with CurrentSourceMappable {
  final Voltage? voltage;
  const CurrentSource({this.voltage}) : super._();
}

@MappableClass(discriminatorValue: 'idealDiode')
class IdealDiode extends BranchModel with IdealDiodeMappable {
  final Voltage? voltage;
  const IdealDiode({this.voltage}) : super._();
}

@MappableClass(discriminatorValue: 'resistor')
class Resistor extends BranchModel with ResistorMappable {
  final Resistance? resistance;
  Resistor({this.resistance}) : super._();
}

@MappableClass(discriminatorValue: 'realDiode')
class RealDiode extends BranchModel with RealDiodeMappable {
  final Current? i0;
  final Voltage? vt;
  final double? n;
  const RealDiode({this.i0, this.vt, this.n}) : super._();
}

@MappableClass(discriminatorValue: 'voltageSource')
class VoltageSource extends BranchModel with VoltageSourceMappable {
  final Voltage? voltage;
  const VoltageSource({this.voltage}) : super._();
}

@MappableClass(discriminatorValue: 'zenerDiode')
class ZenerDiode extends BranchModel with ZenerDiodeMappable {
  final Voltage? vzt;
  final Resistance? rzt;
  final Current? izt;

  const ZenerDiode({this.vzt, this.rzt, this.izt}) : super._();
}

@MappableClass()
class Resistance with ResistanceMappable {
  final double ohms;
  const Resistance({required this.ohms});
  double get milliOhms => ohms * 1000;
  double get kiloOhms => ohms / 1000;
}

@MappableClass()
class Voltage with VoltageMappable {
  final double volts;
  const Voltage({required this.volts});
  double get milliVolts => volts * 1000;
}

@MappableClass()
class Current with CurrentMappable {
  final double a;
  const Current({required this.a});
  double get amps => a;
  double get milliAmps => a * 1000;
}
