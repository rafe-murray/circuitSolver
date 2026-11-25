import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/core/themes/circuit_theme.dart';
import 'package:uuid/uuid_value.dart';

/// Radius, in canvas units, of an endpoint's circular hitbox.
const double endpointHitRadius = 12.0;

/// The components and endpoints in [circuit] whose hitbox intersects [region].
///
/// A component is captured when [region] meets either its oriented
/// body-plus-leads rectangle or the circle at its centre; an endpoint is
/// captured when [region] meets the circle around its position. An invalid
/// region captures nothing.
Selection lassoSelection(CircuitModel circuit, LassoRegion region) {
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

/// Every component and endpoint in [circuit].
Selection selectAllOf(CircuitModel circuit) => Selection(
  componentIds: circuit.components.map((c) => c.id).toSet(),
  endpointIds: circuit.endpoints.keys.toSet(),
);
