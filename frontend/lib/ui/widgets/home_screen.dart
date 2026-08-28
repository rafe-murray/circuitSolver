import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/circuit_view_model.dart';
import 'package:frontend/ui/widgets/circuit_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circuits = ref.watch(circuitsProvider);
    switch (circuits) {
      case AsyncLoading<List<CircuitModel>>():
        return const Center(child: CircularProgressIndicator());
      case AsyncData<List<CircuitModel>>():
        return Wrap(
          spacing: 10.0,
          children: circuits.value
              .map((circuitModel) => CircuitWidget(circuitModel: circuitModel))
              .toList(),
        );
      case AsyncError<List<CircuitModel>>():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
