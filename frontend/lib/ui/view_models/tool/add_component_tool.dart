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

  CircuitModel Function() addComponentAtPos(CircuitModel circuit, Offset pos) =>
      () {
        print(
          "Adding ${branch.kind} to circuit ${circuit.id} at position $pos",
        );
        final fromEndpoint = EndpointModel(
          pos: pos - Offset(20, 20),
          id: uuid.v7obj(),
        );
        final toEndpoint = EndpointModel(
          pos: pos + Offset(20, 20),
          id: uuid.v7obj(),
        );
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

  CircuitModel Function() addComponent(CircuitModel circuit) =>
      addComponentAtPos(circuit, Offset(50, 50));
}
