import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/home_view_model.dart';
import 'package:frontend/ui/widgets/circuit_widget.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.white, child: CircuitListWidget()),
    );
  }
}

class CreateCircuitWidget extends ConsumerWidget {
  const CreateCircuitWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.watch(homeViewModelProvider.notifier).createCircuit();
      },
      icon: const Icon(Icons.plus_one),
      label: const Text('New Circuit'),
    );
  }
}

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
              (circuitModel) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
                child: InkWell(
                  onTap: () {
                    context.go('/edit/${circuitModel.id.toString()}');
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Text(circuitModel.name ?? "New Circuit"),
                        CircuitWidget(
                          circuitModel: circuitModel,
                          size: const Size(100, 150),
                        ),
                      ],
                    ),
                  ),
                ),
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
