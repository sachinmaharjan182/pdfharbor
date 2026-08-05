import 'dart:io';
import 'dart:typed_data';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pdf/pdf_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/repositories/merge_repository.dart';

class MergeRepositoryImpl implements MergeRepository {
  const MergeRepositoryImpl();

  @override
  Future<Result<String>> mergePdfs({
    required List<String> sourcePaths,
    required String outputName,
  }) async {
    try {
      final documents = <Uint8List>[];
      for (final path in sourcePaths) {
        final file = File(path);
        if (!await file.exists()) return ResultFailure(FileNotFoundFailure(path));
        documents.add(await file.readAsBytes());
      }

      final merged = await PdfEngine.merge(MergeRequest(documents));
      final saved = await OutputFileService.save(merged, _withPdfExtension(outputName));
      return Success(saved.path);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not merge these PDFs: $e'));
    }
  }

  static String _withPdfExtension(String name) {
    return name.toLowerCase().endsWith('.pdf') ? name : '$name.pdf';
  }
}
