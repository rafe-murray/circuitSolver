import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// The [ToolBank] rail on the left selects the active tool; [_CircuitCanvas]
/// renders the circuit and, when a tool is active, wraps it in the tool's
/// input-detection widgets.
class EditorScreen extends ConsumerWidget {
  /// Id of the circuit being edited.
  final UuidValue circuitId;

  const EditorScreen({super.key, required this.circuitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Circuit Solver")),
      body: Row(
        children: [
          ToolBank(
            selectedTool: ref.watch(selectedToolProvider(circuitId: circuitId)),
            onToolSelected: (meta) => ref
                .read(selectedToolProvider(circuitId: circuitId).notifier)
                .select(meta),
          ),
          Expanded(child: _CircuitCanvas(circuitId: circuitId)),
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

  /// Position used when a tool is activated by keyboard rather than a tap.
  static const _keyboardAddPosition = Offset(50, 50);

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Runs [tool] against [circuit] as the action for
  /// [EditorViewModel.updateCircuit].
  void _apply(Tool tool, CircuitModel circuit, Offset position) {
    final viewModel = ref.read(
      editorViewModelProvider(circuitId: widget.circuitId).notifier,
    );
    switch (tool) {
      case AddComponentTool():
        viewModel.updateCircuit(tool.addComponentAtPos(circuit, position));
    }
  }

  /// Wraps [CircuitView] in the input-detection widgets for [tool].
  Widget _withToolInput(Tool tool, CircuitModel circuit) {
    switch (tool) {
      case AddComponentTool():
        return AddComponentKeyboardListener(
          focusNode: _focusNode,
          addComponentCallback: () =>
              _apply(tool, circuit, _keyboardAddPosition),
          child: AddComponentCanvasGestureDetector(
            addComponentCallback: (position) => _apply(tool, circuit, position),
            child: CircuitView(circuitModel: circuit),
          ),
        );
    }
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
        return _withToolInput(tool, model);
    }
  }
}
