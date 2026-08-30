/// Shared exception types
library;

/// Represents an exception thrown when an item is not found by a collection
class NotFoundException implements Exception {
  /// Human-readable description of what was not found.
  final String message;

  /// Creates a [NotFoundException] with the given [message].
  const NotFoundException(this.message);

  @override
  String toString() {
    return "NotFoundException($message)";
  }
}
