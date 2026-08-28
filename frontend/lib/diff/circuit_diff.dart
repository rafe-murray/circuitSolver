import 'package:diffutil_dart/diffutil.dart';
import 'package:uuid/uuid.dart';
import 'item_diff.dart';
import 'map_diff.dart';
import 'list_diff.dart';

import '../data/model/circuit_models.dart';

/// Represents the difference in state between to [CircuitModel]s
class CircuitDiff {
  final ListDiff<ComponentModel> _componentDiff;
  final ListDiff<WireModel> _wireDiff;
  final MapDiff<UuidValue, EndpointModel> _endpointDiff;
  final ItemDiff<String?> _nameDiff;
  const CircuitDiff(
    ListDiff<ComponentModel> componentDiff,
    ListDiff<WireModel> wireDiff,
    MapDiff<UuidValue, EndpointModel> endpointDiff,
    ItemDiff<String?> nameDiff,
  ) : _componentDiff = componentDiff,
      _wireDiff = wireDiff,
      _endpointDiff = endpointDiff,
      _nameDiff = nameDiff;
  CircuitModel applyTo(CircuitModel circuit) {
    return CircuitModel(
      id: circuit.id,
      name: _nameDiff.applyTo(circuit.name),
      components: _componentDiff.applyTo(circuit.components),
      wires: _wireDiff.applyTo(circuit.wires),
      endpoints: _endpointDiff.applyTo(circuit.endpoints),
    );
  }

  CircuitModel revertFrom(CircuitModel circuit) {
    return CircuitModel(
      id: circuit.id,
      name: _nameDiff.revertFrom(circuit.name),
      components: _componentDiff.revertFrom(circuit.components),
      wires: _wireDiff.revertFrom(circuit.wires),
      endpoints: _endpointDiff.revertFrom(circuit.endpoints),
    );
  }
}

/// Calculates the diff between [oldCircuit] and [newCircuit]
CircuitDiff calculateDiff(CircuitModel oldCircuit, CircuitModel newCircuit) {
  final componentDiff = ListDiff(
    calculateListDiff(
      oldCircuit.components,
      newCircuit.components,
      detectMoves: false,
    ),
  );
  final wireDiff = ListDiff(
    calculateListDiff(oldCircuit.wires, newCircuit.wires, detectMoves: false),
  );
  final endpointDiff = calculateMapDiff(
    oldCircuit.endpoints,
    newCircuit.endpoints,
  );
  final nameDiff = ItemDiff(oldCircuit.name, newCircuit.name);
  return CircuitDiff(componentDiff, wireDiff, endpointDiff, nameDiff);
}
