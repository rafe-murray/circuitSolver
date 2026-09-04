import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';
import 'package:frontend/ui/widgets/circuit_hit_test_view.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/tools/add_component_canvas_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/add_component_keyboard_listener.dart';
import 'package:frontend/ui/widgets/tools/lasso_selection_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/selection_indicators.dart';
import 'package:frontend/ui/widgets/tools/selection_keyboard_listener.dart';
import 'package:uuid/uuid_value.dart';

/// Size of the editor's scrollable canvas, in canvas coordinates.
///
/// The circuit is conceptually unbounded, but [InteractiveViewer] with
/// `constrained: false` hands its child unbounded constraints, and the layered
/// canvas widgets (hit-test targets, selection indicators, tool overlays) need a
/// concrete size to lay out against and to define a hit-test area. This constant
/// is that shared size; it is generously large so components rarely fall
/// outside it.
const Size kEditorCanvasSize = Size(4000, 4000);

/// Renders the circuit inside a pan/zoom [InteractiveViewer] and routes canvas /
/// keyboard input to the active tool.
///
/// One-finger / primary-button drags are claimed by the active tool's gesture
/// detector (drawing, lassoing). The [InteractiveViewer] pans and zooms on
/// trackpad, mouse-wheel and pinch input; a middle-mouse-button drag also pans.
class EditorCanvas extends ConsumerStatefulWidget {
  /// Id of the circuit being edited.
  final UuidValue circuitId;

  const EditorCanvas({super.key, required this.circuitId});

  @override
  ConsumerState<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends ConsumerState<EditorCanvas> {
  final _controller = TransformationController();
  final _focusNode = FocusNode();

  /// Pointer position at the previous middle-mouse-drag event, or `null` when no
  /// middle-mouse pan is in progress.
  Offset? _middlePanAnchor;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _execute(CircuitModel Function() toolCallBack) async {
    await ref
        .read(editorViewModelProvider(circuitId: widget.circuitId).notifier)
        .updateCircuit(toolCallBack);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons & kMiddleMouseButton != 0) {
      _middlePanAnchor = event.position;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final anchor = _middlePanAnchor;
    if (anchor == null || event.buttons & kMiddleMouseButton == 0) return;
    final delta = event.position - anchor;
    _middlePanAnchor = event.position;
    _controller.value = Matrix4.translationValues(delta.dx, delta.dy, 0)
      ..multiply(_controller.value);
  }

  void _endMiddlePan(PointerEvent _) => _middlePanAnchor = null;

  @override
  Widget build(BuildContext context) {
    final circuit = ref.watch(
      editorViewModelProvider(circuitId: widget.circuitId),
    );
    switch (circuit) {
      case AsyncLoading<CircuitModel>():
        return const Center(child: CircularProgressIndicator());
      case AsyncError<CircuitModel>():
        return Center(child: Text("Something went wrong: ${circuit.error}"));
      case AsyncData<CircuitModel>():
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _endMiddlePan,
          onPointerCancel: _endMiddlePan,
          child: InteractiveViewer(
            transformationController: _controller,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 8,
            child: SizedBox.fromSize(
              size: kEditorCanvasSize,
              child: _toolLayer(circuit.value),
            ),
          ),
        );
    }
  }

  Widget _toolLayer(CircuitModel model) {
    final selectedTool = ref.watch(
      selectedToolProvider(circuitId: widget.circuitId),
    );
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
          focusNode: _focusNode,
          addComponentCallback: () => _execute(tool.addComponent(model)),
          child: AddComponentCanvasGestureDetector(
            branch: tool.branch,
            addComponentCallback: (pos) =>
                _execute(tool.addComponentAtPos(model, pos)),
            addComponentBetweenCallback: ({required from, required to}) =>
                _execute(tool.addComponentBetween(model, from: from, to: to)),
            child: CircuitView(circuitModel: model),
          ),
        );
      case LassoTool():
        final selection = ref.read(
          currentSelectionProvider(circuitId: widget.circuitId).notifier,
        );
        return SelectionKeyboardListener(
          focusNode: _focusNode,
          onClear: selection.clear,
          onSelectAll: () => selection.set(tool.selectAll()),
          child: LassoSelectionGestureDetector(
            onLassoComplete: (region) =>
                selection.set(tool.selectWithin(region)),
            onTapClear: selection.clear,
            child: Stack(
              children: [
                CircuitHitTestView(circuitModel: model),
                SelectionIndicators(circuitModel: model),
              ],
            ),
          ),
        );
    }
  }
}
