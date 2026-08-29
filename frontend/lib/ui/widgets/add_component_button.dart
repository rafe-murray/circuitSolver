import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/widgets/component_icon.dart';

class AddComponentButton extends StatelessWidget {
  final void Function()? onPressed;
  final BranchModel branch;
  const AddComponentButton({super.key, this.onPressed, required this.branch});

  @override
  Widget build(BuildContext context) {
    final String branchType;
    switch (branch) {
      case CurrentSource():
        branchType = 'Current Source';
      case IdealDiode():
        branchType = 'Ideal Diode';
      case RealDiode():
        branchType = 'Real Diode';
      case Resistor():
        branchType = 'Resistor';
      case VoltageSource():
        branchType = 'Voltage Source';
      case ZenerDiode():
        branchType = 'Zener Diode';
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        children: [
          ComponentIcon(branch: branch),
          Text("Add $branchType"),
        ],
      ),
    );
  }
}
