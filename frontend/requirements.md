# Circuit solver

Circuit Solver is an interactive circuit editor and solver built with flutter.
Very few features require the use of a backend, instead local storage with
sqlite is used.

## Features

### Creating and Editing a circuit

#### 1.1 Add component

- User drags a component from a bank of available components onto the canvas
- If one endpoint of the component is close to an existing component's endpoint,
  the new component will snap to the existing one and form a connection
- They can also click on the element in the bank to add a component directly to
  an area near the centre of the canvas

#### 1.2 Translate component

- User drags a component already on the canvas to a new location
- Endpoints of connected components remain connected (i.e., they move with the
  component)
- If an endpoint of the moved component is close to an existing component's
  endpoint, the new component will snap to the existing one and form a
  connection

#### 1.3 Make selection

- User drags mouse over area and selects all the components that are contained
  within
- Subsequent operations apply to the entire selection until a new selection is
  made or the area is deselected

#### 1.4 Rotate component

- User selects the rotate tool from the command palette and makes a selection
  (in either order)
- They can then view rotate controls around the components
- Rotations snap to each 90 degree increment and to the angles of nearby
  components

#### 1.5 Remove component

- Either the user makes a selection then selects the delete tool or the user
  uses the delete tool and clicks on existing components

#### 1.6 Undo last edit

- User selects undo and the last edit action they took is undone

### 2 Units/values

#### 2.1 Change component variables

- Before solving, a user should be able to change the default
  resistance/voltage/current/etc. of a component by clicking on it

#### 2.2 View component variables

- Component variables should be displayed alongside each component in the user's
  chosen units

#### 2.3 Change Units

- Users should be able to change their chosen units between SI and imperial from
  their settings page

### 3. Solving a circuit

#### 3.1 Solve the circuit

- User selects solve
- Then, they input enough voltages and currents to make the circuit solvable
- The system solves the circuit using the api from
  `../native_lib/include/circuit_solver/api.h` using the schema from
  `../native_lib/circuit_solver/v1/circuit_graph_message.proto`

### 4. Saving circuits

#### 4.1 Save current circuit

- User selects save
- Given a dialog to choose name
- Saved to disk
- Also triggered when leaving the app without saving

#### 4.2 Load circuit

- From the landing page of the app, the user can open their saved circuits

## Available components

- Resistor
- Wire
- Voltage source
- Current source
- Real diode
- Ideal diode
- Zener diode

## Keyboard shortcuts

- Each action should be mapped to the industry-standard keyboard shortcut for
  the feature (e.g. control/command-a for select all)
