import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/circuit_view_model.dart';
import 'package:frontend/ui/widgets/circuit_widget.dart';
import 'package:frontend/ui/widgets/component_painter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid_value.dart';

part 'editor_screen.g.dart';

@riverpod
UuidValue circuitId(Ref ref) {
  return UuidValue.fromString('e6ae4d2d-60ff-426d-a5a8-827ec5cdf887');
}

class EditorScreen extends ConsumerWidget {
  final UuidValue circuitId;
  const EditorScreen({super.key, required this.circuitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circuit = ref.watch(circuitModelProvider);
    switch (circuit) {
      case AsyncLoading<CircuitModel>():
        return const Center(child: CircularProgressIndicator());
      case AsyncData<CircuitModel>():
        return CircuitWidget(circuitModel: circuit.value);
      case AsyncError<CircuitModel>():
        print("Error getting CircuitModel: ${circuit.error}");
        return Center(child: Text("Something went wrong..."));
    }
  }
}
