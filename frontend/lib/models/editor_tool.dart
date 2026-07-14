import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The active editing tool in the circuit editor.
///
/// Each tool changes how pointer and keyboard events are interpreted on the
/// canvas. Tool-switching shortcuts follow Photoshop conventions where an
/// industry standard exists, then mnemonics, then the Shift+letter rule.
enum EditorTool {
  /// Moves the current selection. Drag on a component to move it; connected
  /// components have their linked endpoints dragged along in real time.
  ///
  /// Keyboard shortcut: `V` (Photoshop convention).
  move,

  /// Allows inserting components from the component bank.
  ///
  /// While active, the component bank appears in the left panel. Clicking the
  /// canvas inserts the currently selected component type. Individual component
  /// types can also be selected via their key shortcut.
  ///
  /// Keyboard shortcut: `Shift+A`.
  addComponent,

  /// Rubber-band (marquee) rectangular selection.
  ///
  /// Drag to draw a rectangle; all components whose centres fall inside are
  /// selected. Hold `Shift` to add to the selection; hold `Alt` to subtract.
  ///
  /// Keyboard shortcut: `M` (Photoshop convention).
  selection,

  /// Free-form lasso selection.
  ///
  /// Drag to trace a shape; all components whose centres fall inside are
  /// selected. Shift/Alt modifiers work identically to [selection].
  ///
  /// Keyboard shortcut: `L` (Photoshop convention).
  lasso,

  /// Magic-wand selection: selects all components connected to the tapped one.
  ///
  /// Shift/Alt modifiers work identically to [selection].
  ///
  /// Keyboard shortcut: `W` (Photoshop convention).
  wand,

  /// Rotates the selection around its centroid.
  ///
  /// Drag to rotate by any amount; snaps to 90° increments when close.
  ///
  /// Keyboard shortcut: `E` (mnemonic: rEtate / matches Photoshop Eraser slot
  /// but "E" is available here; "R" is kept as a quick 90° rotation shortcut).
  rotate,

  /// Transform tool: drag component midpoints to move them, drag endpoints to
  /// stretch them. Hold `Alt` to move a single component without following
  /// its connected components.
  ///
  /// Keyboard shortcut: `T` (Photoshop Free Transform).
  transform,

  /// Zooms the canvas in (click) or out (Alt+click). Also enables pinch-zoom.
  ///
  /// Keyboard shortcut: `Z` (Photoshop convention; without Ctrl modifier).
  zoom,
}

/// Metadata for each [EditorTool].
extension EditorToolInfo on EditorTool {
  /// Human-readable label shown in tooltips.
  String get label {
    switch (this) {
      case EditorTool.move:
        return 'Move';
      case EditorTool.addComponent:
        return 'Add Component';
      case EditorTool.selection:
        return 'Selection';
      case EditorTool.lasso:
        return 'Lasso';
      case EditorTool.wand:
        return 'Wand';
      case EditorTool.rotate:
        return 'Rotate';
      case EditorTool.transform:
        return 'Transform';
      case EditorTool.zoom:
        return 'Zoom';
    }
  }

  /// The keyboard shortcut description shown in the tooltip.
  String get shortcutLabel {
    switch (this) {
      case EditorTool.move:
        return 'V';
      case EditorTool.addComponent:
        return 'Shift+A';
      case EditorTool.selection:
        return 'M';
      case EditorTool.lasso:
        return 'L';
      case EditorTool.wand:
        return 'W';
      case EditorTool.rotate:
        return 'E';
      case EditorTool.transform:
        return 'T';
      case EditorTool.zoom:
        return 'Z';
    }
  }

  /// The icon representing this tool in the palette.
  IconData get icon {
    switch (this) {
      case EditorTool.move:
        return Icons.open_with;
      case EditorTool.addComponent:
        return Icons.add_circle_outline;
      case EditorTool.selection:
        return Icons.crop_square;
      case EditorTool.lasso:
        return Icons.gesture;
      case EditorTool.wand:
        return Icons.auto_fix_high;
      case EditorTool.rotate:
        return Icons.rotate_right;
      case EditorTool.transform:
        return Icons.transform;
      case EditorTool.zoom:
        return Icons.zoom_in;
    }
  }

  /// Returns `true` when [event] matches the keyboard shortcut for this tool.
  ///
  /// Does not match when Ctrl or Cmd is pressed (to avoid clashing with
  /// system shortcuts like Ctrl+Z for undo).
  bool matchesKeyEvent(KeyDownEvent event) {
    final ctrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    if (ctrl) return false;

    switch (this) {
      case EditorTool.move:
        return event.logicalKey == LogicalKeyboardKey.keyV && !shift;
      case EditorTool.addComponent:
        return event.logicalKey == LogicalKeyboardKey.keyA && shift;
      case EditorTool.selection:
        return event.logicalKey == LogicalKeyboardKey.keyM && !shift;
      case EditorTool.lasso:
        return event.logicalKey == LogicalKeyboardKey.keyL && !shift;
      case EditorTool.wand:
        return event.logicalKey == LogicalKeyboardKey.keyW && !shift;
      case EditorTool.rotate:
        return event.logicalKey == LogicalKeyboardKey.keyE && !shift;
      case EditorTool.transform:
        return event.logicalKey == LogicalKeyboardKey.keyT && !shift;
      case EditorTool.zoom:
        // Z without Ctrl (Ctrl+Z = undo)
        return event.logicalKey == LogicalKeyboardKey.keyZ && !shift;
    }
  }
}
