import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pdf/pdf_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/repositories/security_repository.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  const SecurityRepositoryImpl();

  @override
  Future<Result<bool>> isEncrypted(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return ResultFailure(FileNotFoundFailure(path));
      return Success(await PdfEngine.isEncrypted(await file.readAsBytes()));
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> protect({
    required String sourcePath,
    required String password,
  }) {
    return _write(
      sourcePath: sourcePath,
      newPassword: password,
      suffix: 'protected',
    );
  }

  @override
  Future<Result<String>> removePassword({
    required String sourcePath,
    required String password,
  }) {
    return _write(
      sourcePath: sourcePath,
      newPassword: '',
      currentPassword: password,
      suffix: 'unlocked',
    );
  }

  Future<Result<String>> _write({
    required String sourcePath,
    required String newPassword,
    required String suffix,
    String? currentPassword,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return ResultFailure(FileNotFoundFailure(sourcePath));

      final bytes = await PdfEngine.setPassword(
        SetPasswordRequest(
          source: await file.readAsBytes(),
          newPassword: newPassword,
          currentPassword: currentPassword,
        ),
      );

      final name = '${p.basenameWithoutExtension(sourcePath)} $suffix.pdf';
      final saved = await OutputFileService.save(bytes, name);
      return Success(saved.path);
    } on WrongPasswordException {
      return const ResultFailure(IncorrectPasswordFailure());
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not update this PDF: $e'));
    }
  }
}
