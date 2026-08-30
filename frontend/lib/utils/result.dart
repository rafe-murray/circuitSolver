/// A lightweight `Result` type for operations that may fail without throwing.
///
/// [Result] is a sealed hierarchy with exactly two variants, [Ok] and [Error],
/// so callers can exhaustively `switch` on an instance. The [FutureResult]
/// extension provides the same operations on a `Future<Result<T>>`, which is the
/// shape most repository and service methods return.
library;

/// Result represents the result of an operation that might fail.
///
/// Instances are either an [Ok] carrying a value of type [T] or an [Error]
/// carrying an [Exception]. Consumers should use a `switch` to check possible
/// values.
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error) = Error._;

  /// Applies [f] to the value of an [Ok] and returns a new [Ok] with the
  /// result; an [Error] is returned unchanged (with its type widened to
  /// `Result<U>`).
  ///
  /// Use this to chain value transformations without unwrapping.
  Result<U> transform<U>(U Function(T) f) {
    Result<T> localThis = this;
    switch (localThis) {
      case Ok():
        final test = f(localThis.value);
        return Result.ok(test);
      case Error():
        return Result.error(localThis.error);
    }
  }

  /// Returns the value of an [Ok], or throws the contained [Exception] if this
  /// is an [Error].
  T valueOrThrow() {
    Result<T> localThis = this;
    switch (localThis) {
      case Ok():
        return localThis.value;
      case Error():
        throw localThis.error;
    }
  }
}

/// The success variant of [Result], holding a [value] of type [T].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// The successful value
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// The failure variant of [Result], holding the [error] that occurred.
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// The exception describing why the operation failed.
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}

/// Async counterparts of the [Result] methods.
extension FutureResult<T> on Future<Result<T>> {
  /// Applies [f] to the value of an [Ok] wrapped by the [Future] and returns a new `Future<Ok>` with the
  /// result; a `Future<Error>` is returned unchanged (with its type widened to
  /// `Future<Result<U>>`).
  Future<Result<U>> transform<U>(U Function(T) f) async {
    return (await this).transform(f);
  }

  /// Returns a [Future] wrapping the successful value, or throws the wrapped [Exception]
  Future<T> valueOrThrow() async {
    return (await this).valueOrThrow();
  }
}
