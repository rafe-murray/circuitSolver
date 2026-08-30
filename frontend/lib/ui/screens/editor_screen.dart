import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';
import 'package:frontend/ui/widgets/tools/add_component_canvas_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/add_component_keyboard_listener.dart';
import 'package:uuid/uuid_value.dart';

/// Screen for viewing and editing a single circuit.
///
/// The [ToolBank] card floats at the top-left and selects the active tool;
/// [_CircuitCanvas] renders the circuit and, when a tool is active, wraps it in
/// the tool's input-detection widgets.
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
          Positioned.fill(child: _CircuitCanvas(circuitId: circuitId)),
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

/// Renders the circuit and routes canvas / keyboard input to the active tool.
class _CircuitCanvas extends ConsumerStatefulWidget {
  const _CircuitCanvas({required this.circuitId});

  final UuidValue circuitId;

  @override
  ConsumerState<_CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends ConsumerState<_CircuitCanvas> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _execute(CircuitModel Function() toolCallBack) async {
    await ref
        .read(editorViewModelProvider(circuitId: widget.circuitId).notifier)
        .updateCircuit(toolCallBack);
  }

  @override
  Widget build(BuildContext context) {
    final circuit = ref.watch(
      editorViewModelProvider(circuitId: widget.circuitId),
    );
    final selectedTool = ref.watch(
      selectedToolProvider(circuitId: widget.circuitId),
    );
    switch (circuit) {
      case AsyncLoading<CircuitModel>():
        return const Center(child: CircularProgressIndicator());
      case AsyncError<CircuitModel>():
        return Center(child: Text("Something went wrong: ${circuit.error}"));
      case AsyncData<CircuitModel>():
        final model = circuit.value;
        if (selectedTool == null) {
          return CircuitView(circuitModel: model);
        }
        final tool = Tool.fromMeta(
          meta: selectedTool,
          uuid: ref.read(uuidProvider),
          circuit: model,
        );
        switch (tool) {
          case AddComponentTool():
            return AddComponentKeyboardListener(
              addComponentCallback: () =>
                  _execute(tool.addComponent(circuit.value)),
              focusNode: _focusNode,
              child: AddComponentCanvasGestureDetector(
                branch: tool.branch,
                addComponentCallback: (pos) =>
                    _execute(tool.addComponentAtPos(circuit.value, pos)),
                addComponentBetweenCallback: ({required from, required to}) =>
                    _execute(
                      tool.addComponentBetween(
                        circuit.value,
                        from: from,
                        to: to,
                      ),
                    ),
                child: CircuitView(circuitModel: circuit.value),
              ),
            );
        }
    }
  }
}
