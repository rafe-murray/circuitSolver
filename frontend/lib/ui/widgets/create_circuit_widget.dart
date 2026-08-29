import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/ui/view_models/home_view_model.dart';

class CreateCircuitWidget extends ConsumerWidget {
  const CreateCircuitWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.watch(homeViewModelProvider.notifier).createCircuit();
      },
      icon: const Icon(Icons.add),
      label: const Text('New Circuit'),
    );
  }
}
