import 'package:frontend/data/repositories/circuit_repository.dart';
import 'package:frontend/data/repositories/circuit_repository_local.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@riverpod
CircuitRepository circuitRepository(Ref ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  final localSolverService = ref.watch(localSolverServiceProvider);
  return CircuitRepositoryLocal(
    localSolverService: localSolverService,
    localStorageService: localStorageService,
  );
}

@riverpod
LocalSolverService localSolverService(Ref ref) {
  return LocalSolverService();
}

@riverpod
LocalStorageService localStorageService(Ref ref) {
  final db = ref.watch(databaseProvider);
  return LocalStorageService(db: db);
}

@riverpod
CircuitSolverDatabase database(Ref ref) {
  return CircuitSolverDatabase();
}
