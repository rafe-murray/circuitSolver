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
      appBar: AppBar(title: Text("Circuit Solver")),
      body: CircuitListWidget(),
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
      icon: const Icon(Icons.add),
      label: const Text('New Circuit'),
    );
  }
}

enum CircuitMenuOptions { rename, delete }

class CircuitRenameDialog extends StatelessWidget {
  final void Function(String) onSubmit;
  final TextEditingController controller;
  const CircuitRenameDialog({
    super.key,
    required this.onSubmit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rename"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Please enter a new name for the item:"),
          TextField(
            controller: controller,
            autofocus: true,
            selectAllOnFocus: true,
            onSubmitted: (newName) {
              onSubmit(newName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            onSubmit(controller.text);
            Navigator.pop(context);
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}

class CircuitCard extends ConsumerWidget {
  final CircuitModel circuitModel;
  const CircuitCard({super.key, required this.circuitModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(circuitModel.name ?? "New Circuit"),
              PopupMenuButton(
                tooltip: '',
                offset: Offset(0.0, 40.0),
                icon: const Icon(Icons.more_vert),
                onSelected: (result) {
                  switch (result) {
                    case CircuitMenuOptions.rename:
                      showDialog(
                        context: context,
                        builder: (context) => CircuitRenameDialog(
                          onSubmit: (newName) {
                            ref
                                .read(homeViewModelProvider.notifier)
                                .renameCircuit(circuitModel.id, newName);
                          },
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: circuitModel.name ?? "",
                              selection: TextSelection(
                                baseOffset: 0,
                                extentOffset: circuitModel.name?.length ?? 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    case CircuitMenuOptions.delete:
                      ref
                          .read(homeViewModelProvider.notifier)
                          .deleteCircuit(circuitModel.id);
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<CircuitMenuOptions>>[
                      const PopupMenuItem(
                        value: CircuitMenuOptions.rename,
                        child: Row(
                          children: [Icon(Icons.edit), Text("Rename")],
                        ),
                      ),
                      const PopupMenuItem(
                        value: CircuitMenuOptions.delete,
                        child: Row(
                          children: [Icon(Icons.delete), Text("Delete")],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          CircuitWidget(circuitModel: circuitModel, size: const Size(100, 150)),
        ],
      ),
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
