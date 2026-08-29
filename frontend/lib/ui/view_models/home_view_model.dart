import 'package:frontend/ui/view_models/circuit_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/repository_providers.dart';
import '../../data/model/circuit_models.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<List<CircuitModel>> build() async {
    return (await ref.watch(circuitRepositoryProvider).getAllCircuits())
        .valueOrThrow();
  }

  Future<void> createCircuit() async {
    final id = ref.read(uuidProvider).v7obj();
    try {
      (await ref
              .read(circuitRepositoryProvider)
              .saveCircuit(
                CircuitModel(
                  id: id,
                  name: null,
                  components: [],
                  wires: [],
                  endpoints: {},
                ),
              ))
          .valueOrThrow();
      // Refetch from db
      ref.invalidateSelf();
    } catch (error) {
      print("Error creating circuit: ${error.toString()}");
    }
  }
}
