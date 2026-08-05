import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pdf/pdf_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/repositories/split_repository.dart';

class SplitRepositoryImpl implements SplitRepository {
  const SplitRepositoryImpl();

  @override
  Future<Result<int>> pageCount(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return ResultFailure(FileNotFoundFailure(path));
      final count = await PdfEngine.pageCount(await file.readAsBytes());
      return Success(count);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> splitIntoFiles({
    required String sourcePath,
    required List<List<int>> pageGroups,
    required String outputBaseName,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return ResultFailure(FileNotFoundFailure(sourcePath));
      final bytes = await file.readAsBytes();

      final savedPaths = <String>[];
      final isMultiFile = pageGroups.length > 1;

      for (var i = 0; i < pageGroups.length; i++) {
        final group = pageGroups[i];
        if (group.isEmpty) continue;

        final extracted = await PdfEngine.extractPages(ExtractPagesRequest(bytes, group));
        // Single-output splits keep a clean name; per-page splits get a
        // 1-based suffix matching the source page number.
        final name = isMultiFile
            ? '$outputBaseName ${group.first + 1}.pdf'
            : '$outputBaseName.pdf';
        final saved = await OutputFileService.save(extracted, name);
        savedPaths.add(saved.path);
      }

      if (savedPaths.isEmpty) {
        return const ResultFailure(UnexpectedFailure('No pages matched your selection'));
      }
      return Success(savedPaths);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not split this PDF: $e'));
    }
  }
}
