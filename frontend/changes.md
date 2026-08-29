# Needed changes

## Modal editing

Editing the circuit should be accomplished by the user selecting different tools
from a tool palette. While they have a particular tool selected, it changes how
mouse and keyboard activity works for the editor. Most of these tools should
mimic their photoshop counterparts for anything that is unclear from the
specification.

### Move

While using the move tool, dragging the mouse on the screen moves the selection.

### Add component

While using this tool, a bank of available components is available as a palette
on the left, underneath the tool palette. Clicking on one of these components
selects it for insertion. This is reflected in the component palette. When the
user clicks on the canvas with a component selected for insertion, it inserts
that component at their cursor. After insertion, the current selection for the
editor is set to the new component. A component may also be selected for
insertion by pressing the following keys while the add component tool is
selected:

| Key | Component to add |
| --- | ---------------- |
| c   | current source   |
| i   | ideal diode      |
| d   | real diode       |
| r   | resistor         |
| v   | voltage source   |
| w   | wire             |
| z   | zener diode      |

### Selection tool

This tool lets the user draw a selection box. All components within the box are
selected. Similar to photoshop selection tools, the user should be able to add
or subtract from the current selection by holding a modifier key.

#### Lasso

The user can choose to use the lasso version of the selection tool to select
anything within the drawn shape. Similar addition and subtraction logic applies.

#### Wand

This wand selects all components connected to the component that gets selected.
Similar addition and subtraction logic applies

### Rotate

While using this tool, the user can rotate the current selection. This allows
rotation by any amount, but it snaps to 90 degree rotations from the original
rotation. If the entire selection contains components orthogonal to each other,
the rotation tool should snap to rotations that are orthogonal to those
components.

### Transform

When the user selects this tool, blue points appear at component mid- and
endpoints. Dragging from the midpoint of a component moves that component.
Dragging from an endpoint moves that endpoint and the endpoint(s) of any
connected component(s). When moving a component, the connected endpoints of any
other components are moved in sync.

#### Single component

While holding alt with this tool (or by selecting the alternate version), the
user can move a single component. This means that the endpoints of connected
components will not be moved, potentially breaking these connections. When this
tool is selected, the blue selection points at connected endpoints have a line
through the centre to allow users to select which of the two (or more) connected
endpoints they want to select. They should also be able to cycle through which
connected endpoint is selected

### Zoom

This tool allows the user to zoom in or out of the canvas.

## Changing modes

Changing modes can be accomplished in two ways: either the user clicks a tool
from the tool palette or they press the keyboard shortcut associated with the
tool

These keyboard shortcuts should be decided in the following way:

1. If an industry standard shortcut exists, use that (e.g. photoshop or google
   docs)
1. Otherwise, if there is an available keyboard shortcut that matches a mnemonic
   (e.g. R for rotate), use that
1. Otherwise, use your judgement. Tool selection from the tool palette should
   always be shift-letter.

While hovering over a button on the tool palette, the associated keyboard
shortcut should be shown on the tooltip.

## Component connections

Components are considered "Connected" if their endpoints intersect. By default
when transforming (moving, rotating) a component, connections are maintained by
moving the endpoints of components that are not selected. For example if there
is a resistor connected to a voltage source and the user translates the resistor
with the move tool, the voltage source's endpoint that connects to the resistor
will move with it, while the other endpoint remains fixed.
