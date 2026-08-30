import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/home_view_model.dart';
import 'package:frontend/ui/widgets/circuit_card.dart';
import 'package:frontend/ui/widgets/create_circuit_widget.dart';
import 'package:go_router/go_router.dart';

class CircuitListWidget extends ConsumerWidget {
  const CircuitListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circuits = ref.watch(homeViewModelProvider);
    switch (circuits) {
      case AsyncLoading<List<CircuitModel>>():
        return const Center(child: CircularProgressIndicator());
      case AsyncData<List<CircuitModel>>():
        return Wrap(
          spacing: 10.0,
          children: [
            CreateCircuitWidget(),
            ...circuits.value.map(
              (circuitModel) => InkWell(
                onTap: () {
                  context.go('/edit/${circuitModel.id.toString()}');
                },
                child: CircuitCard(circuitModel: circuitModel),
              ),
            ),
          ],
        );
      case AsyncError<List<CircuitModel>>():
        print("Error getting circuits: ${circuits.error}");
        return Center(child: Text("Something went wrong..."));
    }
  }
}
