/// Result represents the result of an operation that might fail
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error) = Error._;

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

/// Subclass of Result for values
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// Returned value in result
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// Returned error in result
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}

extension FutureResult<T> on Future<Result<T>> {
  Future<Result<U>> transform<U>(U Function(T) f) async {
    return (await this).transform(f);
  }

  Future<T> valueOrThrow() async {
    return (await this).valueOrThrow();
  }
}
