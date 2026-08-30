import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/home_view_model.dart';
import 'package:frontend/ui/widgets/circuit_rename_dialog.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';

enum CircuitMenuOptions { rename, delete }

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
          CircuitView(
            circuitModel: circuitModel,
            clippedSize: const Size(100, 150),
            scalingFactor: 0.4,
          ),
        ],
      ),
    );
  }
}
