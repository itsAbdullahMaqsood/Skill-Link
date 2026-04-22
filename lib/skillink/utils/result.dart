sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final message) => message,
      };

  Exception? get exceptionOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final exception) => exception,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Exception? exception) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Failure<T>(:final message, :final exception) =>
        failure(message, exception),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.exception]);
  final String message;
  final Exception? exception;
}
