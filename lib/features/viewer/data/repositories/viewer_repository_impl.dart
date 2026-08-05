import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/pdf_bookmark.dart';
import '../../domain/entities/pdf_document_info.dart';
import '../../domain/repositories/viewer_repository.dart';

class ViewerRepositoryImpl implements ViewerRepository {
  const ViewerRepositoryImpl(this._bookmarksBox);

  final Box<Map<dynamic, dynamic>> _bookmarksBox;

  @override
  Future<Result<PdfDocumentInfo>> readDocumentInfo(String path, {String? password}) async {
    PdfDocument? document;
    try {
      final file = File(path);
      if (!await file.exists()) return ResultFailure(FileNotFoundFailure(path));

      final bytes = await file.readAsBytes();
      document = PdfDocument(inputBytes: bytes, password: password);
      final info = document.documentInformation;

      return Success(
        PdfDocumentInfo(
          fileName: p.basename(path),
          sizeBytes: bytes.length,
          pageCount: document.pages.count,
          isEncrypted: document.security.userPassword.isNotEmpty,
          title: _nullIfEmpty(info.title),
          author: _nullIfEmpty(info.author),
          subject: _nullIfEmpty(info.subject),
          keywords: _nullIfEmpty(info.keywords),
          creator: _nullIfEmpty(info.creator),
          producer: _nullIfEmpty(info.producer),
          creationDate: info.creationDate,
          modificationDate: info.modificationDate,
        ),
      );
    } on Exception catch (e) {
      if (_looksLikePasswordError(e)) return const ResultFailure(IncorrectPasswordFailure());
      return ResultFailure(InvalidPdfFailure(e.toString()));
    } finally {
      document?.dispose();
    }
  }

  @override
  Future<Result<bool>> isEncrypted(String path) async {
    PdfDocument? document;
    try {
      final bytes = await File(path).readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      return const Success(false);
    } on Exception catch (e) {
      if (_looksLikePasswordError(e)) return const Success(true);
      return ResultFailure(InvalidPdfFailure(e.toString()));
    } finally {
      document?.dispose();
    }
  }

  @override
  List<PdfBookmarkEntry> bookmarksFor(String documentPath) {
    return _bookmarksBox.values
        .map((raw) => PdfBookmarkEntry.fromJson(Map<String, dynamic>.from(raw)))
        .where((b) => b.documentPath == documentPath)
        .toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  @override
  Future<Result<void>> addBookmark(PdfBookmarkEntry bookmark) async {
    try {
      await _bookmarksBox.put(bookmark.id, bookmark.toJson());
      return const Success(null);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeBookmark(String bookmarkId) async {
    try {
      await _bookmarksBox.delete(bookmarkId);
      return const Success(null);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  static String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

  /// Syncfusion signals a wrong/missing password by throwing with a message
  /// mentioning the password rather than via a typed exception.
  static bool _looksLikePasswordError(Exception e) {
    return e.toString().toLowerCase().contains('password');
  }
}
