import 'diffable.dart';

/// Represents a difference between an old and new top-level item
class ItemDiff<T> implements Diffable<T> {
  final T _oldValue;
  final T _newValue;

  ItemDiff(T oldValue, T newValue) : _oldValue = oldValue, _newValue = newValue;
  @override
  T applyTo(T _) {
    return _newValue;
  }

  @override
  T revertFrom(T _) {
    return _oldValue;
  }
}
