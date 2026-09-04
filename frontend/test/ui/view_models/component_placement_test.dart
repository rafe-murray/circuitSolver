import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/component_placement.dart';
import 'package:uuid/uuid.dart';

void main() {
  CircuitModel emptyCircuit() => CircuitModel(
    id: const Uuid().v7obj(),
    name: 'test',
    components: [],
    wires: [],
    endpoints: {},
  );

  test('insertComponent adds a component with fresh endpoints at from/to', () {
    final circuit = emptyCircuit();

    final result = insertComponent(
      circuit: circuit,
      branch: const VoltageSource(),
      from: const Offset(10, 20),
      to: const Offset(200, 220),
      uuid: const Uuid(),
    )();

    expect(result.components, hasLength(1));
    final component = result.components.single;
    expect(component.branch, isA<VoltageSource>());
    expect(result.endpoints[component.fromId]!.pos, const Offset(10, 20));
    expect(result.endpoints[component.toId]!.pos, const Offset(200, 220));
  });
}
