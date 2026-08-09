import 'package:flutter/foundation.dart';
import 'package:frontend/data/repositories/circuit_repository.dart';

class CircuitViewModel extends ChangeNotifier {
  CircuitViewModel({required CircuitRepository circuitRepository})
    : _circuitRepository = circuitRepository;
  final CircuitRepository _circuitRepository;
}
