import 'package:flutter/foundation.dart';

import '../services/storage.dart';

/// ViewModel for the [LandingPage].
///
/// Loads the list of saved circuits from [StorageService] and exposes delete
/// functionality. Callers listen via [ListenableBuilder].
class LandingViewModel extends ChangeNotifier {
  LandingViewModel({required StorageService storage}) : _storage = storage {
    _load();
  }

  final StorageService _storage;

  List<Circuit> _circuits = [];
  bool _isLoading = true;
  String? _error;

  List<Circuit> get circuits => List.unmodifiable(_circuits);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Reloads the circuit list from storage.
  Future<void> reload() => _load();

  /// Deletes the circuit with [id] and refreshes the list.
  Future<void> deleteCircuit(int id) async {
    await _storage.deleteCircuit(id);
    await _load();
  }

  /// Returns the raw [Circuit] row for loading into the editor.
  Future<Circuit?> getCircuit(int id) => _storage.load(id);

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _circuits = await _storage.list();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
