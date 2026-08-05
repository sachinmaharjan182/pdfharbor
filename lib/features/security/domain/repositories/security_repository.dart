import '../../../../core/error/result.dart';

abstract interface class SecurityRepository {
  /// True when [path] needs a password to open.
  Future<Result<bool>> isEncrypted(String path);

  /// Writes a password-protected copy of [sourcePath].
  Future<Result<String>> protect({
    required String sourcePath,
    required String password,
  });

  /// Writes a decrypted copy. Fails with [IncorrectPasswordFailure] when
  /// [password] doesn't open the document.
  Future<Result<String>> removePassword({
    required String sourcePath,
    required String password,
  });
}
