import 'package:flutter/material.dart';

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
