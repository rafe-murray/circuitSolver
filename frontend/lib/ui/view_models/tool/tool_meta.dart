import 'package:flutter/widgets.dart';

/// Metadata describing a single tool selectable in the editor's tool bank.
///
/// Tools carry no behavior — a tool's gestures and shortcuts are wired by the
/// editor from its [id] (see `tool_catalog.dart` and the editor's
/// `Actions`/`Intent`s). This type only drives the tool-picker UI.
@immutable
final class ToolMeta {
  /// Stable identifier, used to look up the tool's kind and (for component
  /// tools) its branch.
  final String id;

  /// Human-readable name, shown as the button tooltip.
  final String name;

  /// Icon rendered on the tool-bank button.
  final Widget icon;

  const ToolMeta({required this.id, required this.name, required this.icon});
}

/// A set of related tools shown as one tool-bank entry with a flyout.
@immutable
final class ToolGroup {
  /// The tools in this group; the first is the group's default representative.
  final List<ToolMeta> tools;

  const ToolGroup(this.tools);
}
