import 'failure.dart';

/// A `Result<T>` is either [Success] with data or [ResultFailure] with a
/// [Failure]. Repositories and use cases return this instead of throwing,
/// so the presentation layer can exhaustively switch on the outcome.
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(T data) onSuccess, R Function(Failure failure) onFailure) {
    final self = this;
    return switch (self) {
      Success<T>() => onSuccess(self.data),
      ResultFailure<T>() => onFailure(self.failure),
    };
  }

  bool get isSuccess => this is Success<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        ResultFailure<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        ResultFailure<T>(:final failure) => failure,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}
