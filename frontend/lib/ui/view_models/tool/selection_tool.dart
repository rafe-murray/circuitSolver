part of 'tool.dart';

/// Tools that select existing circuit items rather than mutating the circuit.
///
/// Currently the group holds a single sub-tool, the lasso: the user drags a
/// free-form loop and every component and endpoint whose hitbox intersects it
/// becomes selected.
class SelectionTool extends Tool {
  /// Stable id of the lasso sub-tool.
  static const lassoId = "lassoSelect";

  /// Radius, in canvas units, of an endpoint's circular hitbox.
  static const endpointHitRadius = 12.0;

  /// Builds the [ToolMeta] for the selection sub-tool with the given [id].
  static ToolMeta createMeta({required String id}) => ToolMeta._(
    id: id,
    name: "Lasso select",
    icon: const Icon(Icons.gesture, size: 20),
  );

  SelectionTool._({
    required String id,
    required super.uuid,
    required super.circuit,
  }) : super._(meta: createMeta(id: id));

  /// The components and endpoints whose hitbox intersects [region].
  ///
  /// A component is captured when [region] meets either its oriented
  /// body-plus-leads rectangle or the circle at its centre; an endpoint is
  /// captured when [region] meets the circle around its position.
  Selection selectWithin(LassoRegion region) {
    if (!region.isValid) return Selection.empty;
    final radius = CircuitTheme.editor().componentRadius;

    final componentIds = <UuidValue>{};
    for (final component in circuit.components) {
      final from = circuit.endpoints[component.fromId]?.pos;
      final to = circuit.endpoints[component.toId]?.pos;
      if (from == null || to == null) continue;
      final centre = (from + to) / 2;
      final hit =
          region.intersectsPolygon(orientedRectCorners(from, to, radius)) ||
          region.intersectsCircle(centre, radius);
      if (hit) componentIds.add(component.id);
    }

    final endpointIds = <UuidValue>{};
    for (final entry in circuit.endpoints.entries) {
      if (region.intersectsCircle(entry.value.pos, endpointHitRadius)) {
        endpointIds.add(entry.key);
      }
    }

    return Selection(componentIds: componentIds, endpointIds: endpointIds);
  }

  /// Every component and endpoint in the circuit.
  Selection selectAll() => Selection(
    componentIds: circuit.components.map((c) => c.id).toSet(),
    endpointIds: circuit.endpoints.keys.toSet(),
  );
}

/// The selection tool group shown in the editor's tool bank.
final selectionToolGroup = ToolGroup([
  SelectionTool.createMeta(id: SelectionTool.lassoId),
]);

/// Constructors for each selection sub-tool, keyed by [ToolMeta.id].
final Map<
  String,
  Tool Function({required Uuid uuid, required CircuitModel circuit})
>
selectionToolConstructors = {
  SelectionTool.lassoId: ({required uuid, required circuit}) =>
      SelectionTool._(id: SelectionTool.lassoId, uuid: uuid, circuit: circuit),
};
