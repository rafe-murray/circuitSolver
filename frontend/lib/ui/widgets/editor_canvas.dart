import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/editor_shortcuts.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/view_models/tool/tool_catalog.dart';
import 'package:frontend/ui/widgets/circuit_hit_test_view.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/tools/add_component_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/lasso_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/selection_indicators.dart';
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

/// Renders the circuit inside a pan/zoom [InteractiveViewer] and mounts the
/// active tool's gesture detector and keyboard shortcuts.
///
/// One-finger / primary-button drags are claimed by the active tool's gesture
/// detector (drawing, lassoing). The [InteractiveViewer] pans and zooms on
/// trackpad, mouse-wheel and pinch input; a middle-mouse-button drag also pans.
///
/// The tool's gestures and shortcuts dispatch [Intent]s that are resolved by
/// the `Actions` widget wrapping the editor screen.
class EditorCanvas extends ConsumerStatefulWidget {
  /// Id of the circuit being edited.
  final UuidValue circuitId;

  const EditorCanvas({super.key, required this.circuitId});

  @override
  ConsumerState<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends ConsumerState<EditorCanvas> {
  final _controller = TransformationController();

  /// Pointer position at the previous middle-mouse-drag event, or `null` when no
  /// middle-mouse pan is in progress.
  Offset? _middlePanAnchor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              child: _ToolLayer(
                circuitId: widget.circuitId,
                model: circuit.value,
              ),
            ),
          ),
        );
    }
  }
}

/// The circuit plus the active tool's gesture detector and shortcuts.
///
/// A plain [Focus] node inside the per-tool [Shortcuts] holds keyboard focus,
/// so both the per-tool shortcuts and the editor-wide shortcuts (mounted higher
/// up) sit above the focused node and receive key events.
class _ToolLayer extends ConsumerWidget {
  const _ToolLayer({required this.circuitId, required this.model});

  final UuidValue circuitId;
  final CircuitModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(selectedToolProvider(circuitId: circuitId));
    return Shortcuts(
      shortcuts: shortcutsForTool(tool),
      child: Focus(
        autofocus: true,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            _canvasFor(tool),
            // The selection can be set from an editor-wide shortcut under any
            // tool, so its indicators are always drawn.
            SelectionIndicators(circuitModel: model),
          ],
        ),
      ),
    );
  }

  Widget _canvasFor(ToolMeta? tool) {
    switch (toolKindOf(tool)) {
      case EditorToolKind.none:
        return CircuitView(circuitModel: model);
      case EditorToolKind.addComponent:
        return AddComponentGestureDetector(
          branch: branchOf(tool!)!,
          child: CircuitView(circuitModel: model),
        );
      case EditorToolKind.lasso:
        return LassoGestureDetector(
          child: CircuitHitTestView(circuitModel: model),
        );
    }
  }
}
