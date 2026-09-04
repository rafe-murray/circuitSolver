import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/widgets/editor_canvas.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';
import 'package:uuid/uuid_value.dart';

/// Screen for viewing and editing a single circuit.
///
/// The [ToolBank] card floats at the top-left and selects the active tool;
/// [EditorCanvas] renders the circuit inside a pan/zoom viewport and, when a
/// tool is active, routes canvas input to it.
class EditorScreen extends ConsumerWidget {
  /// Id of the circuit being edited.
  final UuidValue circuitId;

  const EditorScreen({super.key, required this.circuitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Circuit Solver")),
      body: Stack(
        children: [
          Positioned.fill(child: EditorCanvas(circuitId: circuitId)),
          Align(
            alignment: Alignment.topLeft,
            child: ToolBank(
              selectedTool: ref.watch(
                selectedToolProvider(circuitId: circuitId),
              ),
              onToolSelected: (meta) => ref
                  .read(selectedToolProvider(circuitId: circuitId).notifier)
                  .select(meta),
            ),
          ),
        ],
      ),
    );
  }
}
