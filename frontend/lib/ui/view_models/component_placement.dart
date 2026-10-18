import 'dart:ui';

import 'package:frontend/data/model/circuit_models.dart';
import 'package:uuid/uuid.dart';

/// Half-extent, in canvas units, applied around a tapped point to size a
/// component placed by a single tap (rather than a drag).
const double tapComponentHalfExtent = 20.0;

/// Returns a thunk that adds a [branch] component to [circuit], with two fresh
/// endpoints at [from] and [to] in canvas coordinates, and returns the mutated
/// circuit.
///
/// The thunk shape matches [`EditorViewModel.updateCircuit`], which snapshots
/// the circuit for the undo history before and after applying it.
CircuitModel Function() insertComponent({
  required CircuitModel circuit,
  required BranchModel branch,
  required Offset from,
  required Offset to,
  required Uuid uuid,
}) => () {
  final fromEndpoint = EndpointModel(pos: from, id: uuid.v7obj());
  final toEndpoint = EndpointModel(pos: to, id: uuid.v7obj());
  circuit.endpoints.addEntries([
    MapEntry(fromEndpoint.id, fromEndpoint),
    MapEntry(toEndpoint.id, toEndpoint),
  ]);
  circuit.components.add(
    ComponentModel(
      id: uuid.v7obj(),
      fromId: fromEndpoint.id,
      toId: toEndpoint.id,
      branch: branch,
    ),
  );
  return circuit;
};
