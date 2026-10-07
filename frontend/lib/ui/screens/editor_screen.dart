import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/ui/view_models/editor_actions.dart';
import 'package:frontend/ui/view_models/editor_shortcuts.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/widgets/editor_canvas.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';
import 'package:uuid/uuid_value.dart';

/// Screen for viewing and editing a single circuit.
///
/// A [Shortcuts]/[Actions] pair wraps the whole screen: [commonEditorShortcuts]
/// (undo/redo, select-all, clear) and [buildEditorActions] are mounted here,
/// and the active tool adds its own nested [Shortcuts] inside [EditorCanvas].
/// The [ToolBank] card floats at the top-left and selects the active tool; it
/// is wrapped in [ExcludeFocus] so tapping a tool button never steals keyboard
/// focus from the canvas.
class EditorScreen extends ConsumerWidget {
  /// Id of the circuit being edited.
  final UuidValue circuitId;

  const EditorScreen({super.key, required this.circuitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: commonEditorShortcuts,
      child: Actions(
        actions: buildEditorActions(ref, circuitId),
        child: Scaffold(
          appBar: AppBar(title: const Text("Circuit Solver")),
          body: Stack(
            children: [
              Positioned.fill(child: EditorCanvas(circuitId: circuitId)),
              Align(
                alignment: Alignment.topLeft,
                child: ExcludeFocus(
                  child: ToolBank(
                    selectedTool: ref.watch(
                      selectedToolProvider(circuitId: circuitId),
                    ),
                    onToolSelected: (meta) => ref
                        .read(
                          selectedToolProvider(circuitId: circuitId).notifier,
                        )
                        .select(meta),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
