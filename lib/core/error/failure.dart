/// Represents a recoverable failure surfaced to the presentation layer.
///
/// Repositories and use cases return `Result<T>` (see `result.dart`) rather
/// than throwing, so every failure path a screen needs to render is known
/// at compile time instead of being an untyped caught exception.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure(String permissionName)
      : super('Permission required: $permissionName');
}

final class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure(String path) : super('File not found: $path');
}

final class InvalidPdfFailure extends Failure {
  const InvalidPdfFailure([super.message = 'The file is not a valid PDF']);
}

final class IncorrectPasswordFailure extends Failure {
  const IncorrectPasswordFailure() : super('Incorrect password');
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class CancelledFailure extends Failure {
  const CancelledFailure() : super('Operation cancelled');
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong']);
}
