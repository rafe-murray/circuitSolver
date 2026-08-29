import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/circuit_view_model.dart';
import 'package:frontend/ui/widgets/add_component_button.dart';
import 'package:frontend/ui/widgets/circuit_widget.dart';
import 'package:uuid/uuid_value.dart';

class EditorScreen extends ConsumerWidget {
  final UuidValue circuitId;
  const EditorScreen({super.key, required this.circuitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Circuit Solver"),
        actions: [
          AddComponentButton(
            branch: Resistor(),
            onPressed: () {
              ref
                  .read(circuitViewModelProvider(circuitId: circuitId).notifier)
                  .addComponent(Resistor());
            },
          ),
          AddComponentButton(
            branch: VoltageSource(),
            onPressed: () {
              ref
                  .read(circuitViewModelProvider(circuitId: circuitId).notifier)
                  .addComponent(VoltageSource());
            },
          ),
        ],
      ),
      body: EditCircuitWidget(circuitId: circuitId),
    );
  }
}

class EditCircuitWidget extends ConsumerWidget {
  final UuidValue circuitId;
  const EditCircuitWidget({super.key, required this.circuitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circuit = ref.watch(circuitViewModelProvider(circuitId: circuitId));
    switch (circuit) {
      case AsyncLoading<CircuitModel>():
        return const Center(child: CircularProgressIndicator());
      case AsyncData<CircuitModel>():
        return CircuitWidget(circuitModel: circuit.value);
      case AsyncError<CircuitModel>():
        return Center(child: Text("Something went wrong: ${circuit.error}"));
    }
  }
}
