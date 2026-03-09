/// All circuit component types supported by the editor.
enum ComponentType {
  resistor,
  wire,
  voltageSource,
  currentSource,
  realDiode,
  idealDiode,
  zenerDiode;

  /// Human-readable display label.
  String get label => switch (this) {
    ComponentType.resistor => 'Resistor',
    ComponentType.wire => 'Wire',
    ComponentType.voltageSource => 'Voltage source',
    ComponentType.currentSource => 'Current source',
    ComponentType.realDiode => 'Real diode',
    ComponentType.idealDiode => 'Ideal diode',
    ComponentType.zenerDiode => 'Zener diode',
  };

  static ComponentType? fromLabel(String label) {
    for (final t in ComponentType.values) {
      if (t.label == label) return t;
    }
    return null;
  }
}
