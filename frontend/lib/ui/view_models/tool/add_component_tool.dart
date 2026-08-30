part of 'tool.dart';

// ignore: unused_element
String _assertAllIdsPresent(BranchModel branch) {
  switch (branch) {
    case CurrentSource():
      return AddComponentTool.currentSourceId;
    case IdealDiode():
      return AddComponentTool.idealDiodeId;
    case Resistor():
      return AddComponentTool.resistorId;
    case RealDiode():
      return AddComponentTool.realDiodeId;
    case VoltageSource():
      return AddComponentTool.voltageSourceId;
    case ZenerDiode():
      return AddComponentTool.zenerDiodeId;
  }
}

final componentToolIdToBranch = {
  AddComponentTool.resistorId: () => const Resistor(),
  AddComponentTool.idealDiodeId: () => const IdealDiode(),
  AddComponentTool.realDiodeId: () => const RealDiode(),
  AddComponentTool.voltageSourceId: () => const VoltageSource(),
  AddComponentTool.currentSourceId: () => const CurrentSource(),
  AddComponentTool.zenerDiodeId: () => const ZenerDiode(),
};

final addComponentToolGroup = ToolGroup(
  componentToolIdToBranch.entries
      .map(
        (entry) =>
            AddComponentTool.createMeta(id: entry.key, branch: entry.value()),
      )
      .toList(),
);

class AddComponentTool extends Tool {
  final BranchModel branch;

  static const resistorId = "addResistor";
  static const idealDiodeId = "addIdealDiode";
  static const realDiodeId = "addRealDiode";
  static const voltageSourceId = "addVoltageSource";
  static const currentSourceId = "addCurrentSource";
  static const zenerDiodeId = "addZenerDiode";
  static ToolMeta createMeta({
    required String id,
    required BranchModel branch,
  }) => ToolMeta._(
    id: id,
    name: "Add ${branch.kind}",
    icon: ComponentIcon(branch: branch),
  );

  AddComponentTool._({
    required this.branch,
    required String id,
    required super.uuid,
    required super.circuit,
  }) : super._(
         meta: createMeta(id: id, branch: branch),
       ) {
    print("Creating new AddComponentTool");
  }

  /// Builds a callback that adds a component whose two endpoints sit at [from]
  /// and [to] in circuit coordinates.
  CircuitModel Function() addComponentBetween(
    CircuitModel circuit, {
    required Offset from,
    required Offset to,
  }) => () {
    print("Adding ${branch.kind} to circuit ${circuit.id} from $from to $to");
    final fromEndpoint = EndpointModel(pos: from, id: uuid.v7obj());
    final toEndpoint = EndpointModel(pos: to, id: uuid.v7obj());
    final newComponent = ComponentModel(
      id: uuid.v7obj(),
      fromId: fromEndpoint.id,
      toId: toEndpoint.id,
      branch: branch,
    );
    circuit.endpoints.addEntries([
      MapEntry(fromEndpoint.id, fromEndpoint),
      MapEntry(toEndpoint.id, toEndpoint),
    ]);
    circuit.components.add(newComponent);
    return circuit;
  };

  /// Builds a callback that adds a component centered on [pos] with a fixed
  /// default size.
  CircuitModel Function() addComponentAtPos(CircuitModel circuit, Offset pos) =>
      addComponentBetween(
        circuit,
        from: pos - Offset(20, 20),
        to: pos + Offset(20, 20),
      );

  CircuitModel Function() addComponent(CircuitModel circuit) =>
      addComponentAtPos(circuit, Offset(50, 50));
}
