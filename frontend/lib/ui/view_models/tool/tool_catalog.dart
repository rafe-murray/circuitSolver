import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/tool/tool_meta.dart';
import 'package:frontend/ui/widgets/component_icon.dart';

export 'tool_meta.dart';

/// Tool id: add a resistor.
const String resistorToolId = 'addResistor';

/// Tool id: add an ideal diode.
const String idealDiodeToolId = 'addIdealDiode';

/// Tool id: add a real diode.
const String realDiodeToolId = 'addRealDiode';

/// Tool id: add a voltage source.
const String voltageSourceToolId = 'addVoltageSource';

/// Tool id: add a current source.
const String currentSourceToolId = 'addCurrentSource';

/// Tool id: add a Zener diode.
const String zenerDiodeToolId = 'addZenerDiode';

/// Tool id: lasso selection.
const String lassoToolId = 'lassoSelect';

/// The branch each "add component" tool places, keyed by tool id.
final Map<String, BranchModel Function()> componentToolIdToBranch = {
  resistorToolId: () => const Resistor(),
  idealDiodeToolId: () => const IdealDiode(),
  realDiodeToolId: () => const RealDiode(),
  voltageSourceToolId: () => const VoltageSource(),
  currentSourceToolId: () => const CurrentSource(),
  zenerDiodeToolId: () => const ZenerDiode(),
};

ToolMeta _componentToolMeta(String id, BranchModel branch) => ToolMeta(
  id: id,
  name: 'Add ${branch.kind}',
  icon: ComponentIcon(branch: branch, size: 20),
);

/// The "add component" tool group shown in the tool bank.
final ToolGroup addComponentToolGroup = ToolGroup([
  for (final entry in componentToolIdToBranch.entries)
    _componentToolMeta(entry.key, entry.value()),
]);

/// Metadata for the lasso selection tool.
const ToolMeta lassoToolMeta = ToolMeta(
  id: lassoToolId,
  name: 'Lasso select',
  icon: Icon(Icons.gesture, size: 20),
);

/// The selection tool group shown in the tool bank.
final ToolGroup selectionToolGroup = ToolGroup([lassoToolMeta]);

/// Every tool group, in tool-bank order.
final List<ToolGroup> toolGroups = [addComponentToolGroup, selectionToolGroup];

/// The kind of input handling a selected tool needs.
enum EditorToolKind {
  /// Places new components on tap / drag.
  addComponent,

  /// Selects existing items by tracing a lasso.
  lasso,

  /// No tool selected; the canvas is inert.
  none,
}

/// Classifies [meta] so the editor knows which gesture detector and shortcuts
/// to mount. Returns [EditorToolKind.none] when [meta] is `null`.
EditorToolKind toolKindOf(ToolMeta? meta) {
  if (meta == null) return EditorToolKind.none;
  if (componentToolIdToBranch.containsKey(meta.id)) {
    return EditorToolKind.addComponent;
  }
  if (meta.id == lassoToolId) return EditorToolKind.lasso;
  return EditorToolKind.none;
}

/// The branch an "add component" tool places, or `null` if [meta] is not one.
BranchModel? branchOf(ToolMeta meta) =>
    componentToolIdToBranch[meta.id]?.call();
