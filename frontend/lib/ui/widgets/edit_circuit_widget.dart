import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/circuit_view_model.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:uuid/uuid_value.dart';

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
        return CircuitView(circuitModel: circuit.value);
      case AsyncError<CircuitModel>():
        return Center(child: Text("Something went wrong: ${circuit.error}"));
    }
  }
}
