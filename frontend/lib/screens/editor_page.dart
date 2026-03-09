import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/circuit_component.dart';
import '../models/component_type.dart';
import '../services/storage.dart';
import '../viewmodels/canvas_viewmodel.dart';
import '../widgets/canvas.dart';
import '../widgets/component_bank.dart';

/// The main circuit editor screen.
///
/// Layout: [ComponentBank] (left) | [CircuitCanvas] (centre) | Inspector (right).
/// Keyboard shortcuts follow industry conventions (Ctrl/Cmd+Z, Delete, R, etc.).
class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CanvasViewModel>(context);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) => _handleKey(event, vm),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Circuit Solver'),
          actions: [
            _ToolbarButton(
              icon: Icons.undo,
              tooltip: 'Undo (Ctrl+Z)',
              onPressed: vm.canUndo ? vm.undo : null,
            ),
            _ToolbarButton(
              icon: Icons.redo,
              tooltip: 'Redo (Ctrl+Shift+Z)',
              onPressed: vm.canRedo ? vm.redo : null,
            ),
            const VerticalDivider(width: 16),
            _ToolbarButton(
              icon: Icons.rotate_right,
              tooltip: 'Rotate 90° (R)',
              onPressed: vm.selectedIds.isNotEmpty
                  ? vm.rotateSelectionClockwise
                  : null,
            ),
            _ToolbarButton(
              icon: Icons.delete_outline,
              tooltip: 'Delete (Delete / Backspace)',
              onPressed: vm.selectedIds.isNotEmpty ? vm.deleteSelected : null,
            ),
            const VerticalDivider(width: 16),
            _ToolbarButton(
              icon: Icons.save_outlined,
              tooltip: 'Save (Ctrl+S)',
              onPressed: () => _showSaveDialog(context, vm),
            ),
          ],
        ),
        body: Row(
          children: [
            SizedBox(
              width: 200,
              child: ComponentBank(
                onTap: (type) => _addToCentre(type, vm, context),
              ),
            ),
            const Expanded(child: CircuitCanvas()),
            const SizedBox(width: 200, child: _Inspector()),
          ],
        ),
      ),
    );
  }

  void _handleKey(KeyEvent event, CanvasViewModel vm) {
    if (event is! KeyDownEvent) return;

    final ctrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    switch (event.logicalKey) {
      // Undo: Ctrl+Z
      case LogicalKeyboardKey.keyZ when ctrl && !shift:
        vm.undo();
      // Redo: Ctrl+Shift+Z or Ctrl+Y
      case LogicalKeyboardKey.keyZ when ctrl && shift:
        vm.redo();
      case LogicalKeyboardKey.keyY when ctrl:
        vm.redo();
      // Save: Ctrl+S
      case LogicalKeyboardKey.keyS when ctrl:
        _showSaveDialog(context, vm);
      // Delete selected: Delete or Backspace
      case LogicalKeyboardKey.delete:
      case LogicalKeyboardKey.backspace:
        vm.deleteSelected();
      // Rotate: R
      case LogicalKeyboardKey.keyR:
        vm.rotateSelectionClockwise();
      // Select all: Ctrl+A
      case LogicalKeyboardKey.keyA when ctrl:
        for (final c in vm.components) {
          vm.selectComponent(c.id, additive: true);
        }
      // Escape: clear selection
      case LogicalKeyboardKey.escape:
        vm.clearSelection();
      default:
        break;
    }
  }

  /// Places a component near the visual centre of the canvas.
  void _addToCentre(
    ComponentType type,
    CanvasViewModel vm,
    BuildContext context,
  ) {
    const fallback = Offset(400, 300);
    vm.addFromBank(type, fallback);
  }

  Future<void> _showSaveDialog(BuildContext context, CanvasViewModel vm) async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _SaveDialog(initialName: _currentCircuitName(vm)),
    );
    if (name == null || name.trim().isEmpty) return;
    await vm.saveToStorage(storage, name.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved "$name"')));
  }

  /// Returns a sensible default name for the save dialog.
  String _currentCircuitName(CanvasViewModel vm) {
    if (vm.currentCircuitId != null) return '';
    return 'My Circuit';
  }
}

// ---------------------------------------------------------------------------
// Save dialog
// ---------------------------------------------------------------------------

class _SaveDialog extends StatefulWidget {
  const _SaveDialog({required this.initialName});

  final String initialName;

  @override
  State<_SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<_SaveDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save circuit'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Circuit name'),
        onSubmitted: (_) => _submit(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    Navigator.pop(context, _ctrl.text);
  }
}

// ---------------------------------------------------------------------------
// Inspector
// ---------------------------------------------------------------------------

/// Right panel showing properties of the selected component.
class _Inspector extends StatelessWidget {
  const _Inspector();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CanvasViewModel>(context);

    if (vm.selectedIds.isEmpty) {
      return Center(
        child: Text(
          'Select a component\nto view its properties',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    if (vm.selectedIds.length > 1) {
      return Center(
        child: Text(
          '${vm.selectedIds.length} components selected',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final id = vm.selectedIds.first;
    final comp = vm.components.firstWhere((c) => c.id == id);
    return _ComponentInspector(component: comp);
  }
}

class _ComponentInspector extends StatelessWidget {
  const _ComponentInspector({required this.component});

  final CircuitComponent component;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CanvasViewModel>(context, listen: false);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          component.type.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...component.properties.entries.map(
          (e) => _PropertyRow(
            label: e.key,
            value: e.value,
            onChanged: (newVal) {
              vm.updateProperty(component.id, e.key, newVal);
            },
          ),
        ),
      ],
    );
  }
}

class _PropertyRow extends StatefulWidget {
  const _PropertyRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final void Function(double) onChanged;

  @override
  State<_PropertyRow> createState() => _PropertyRowState();
}

class _PropertyRowState extends State<_PropertyRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_PropertyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync the text field when the value changes externally (e.g. after undo).
    if (oldWidget.value != widget.value &&
        _ctrl.text != widget.value.toString()) {
      _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(widget.label)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: Theme.of(context).textTheme.bodySmall,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) {
                final parsed = double.tryParse(text);
                if (parsed != null) widget.onChanged(parsed);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar button
// ---------------------------------------------------------------------------

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
