import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pdf/signature_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/entities/saved_signature.dart';
import '../../domain/repositories/signature_repository.dart';

class SignatureRepositoryImpl implements SignatureRepository {
  const SignatureRepositoryImpl(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  static const _uuid = Uuid();

  @override
  List<SavedSignature> savedSignatures() {
    return _box.values
        .map((raw) => SavedSignature.fromJson(Map<String, dynamic>.from(raw)))
        // Saved signature images live in app-private storage; drop entries
        // whose file has gone missing rather than showing a broken tile.
        .where((signature) => File(signature.imagePath).existsSync())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Result<SavedSignature>> saveSignature(Uint8List pngBytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final signaturesDir = Directory(p.join(dir.path, 'signatures'));
      if (!await signaturesDir.exists()) await signaturesDir.create(recursive: true);

      final id = _uuid.v4();
      final file = File(p.join(signaturesDir.path, '$id.png'));
      await file.writeAsBytes(pngBytes);

      final signature = SavedSignature(
        id: id,
        imagePath: file.path,
        createdAt: DateTime.now(),
      );
      await _box.put(id, signature.toJson());
      return Success(signature);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSignature(String id) async {
    try {
      final raw = _box.get(id);
      if (raw != null) {
        final signature = SavedSignature.fromJson(Map<String, dynamic>.from(raw));
        final file = File(signature.imagePath);
        if (await file.exists()) await file.delete();
      }
      await _box.delete(id);
      return const Success(null);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> pageCount(String sourcePath) async {
    pdfx.PdfDocument? document;
    try {
      if (!await File(sourcePath).exists()) {
        return ResultFailure(FileNotFoundFailure(sourcePath));
      }
      document = await pdfx.PdfDocument.openFile(sourcePath);
      return Success(document.pagesCount);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure(e.toString()));
    } finally {
      await document?.close();
    }
  }

  @override
  Future<Result<String>> placeOnPdf({
    required String sourcePath,
    required String signatureImagePath,
    required SignaturePlacement placement,
  }) async {
    try {
      final stamped = await _stamp(sourcePath, signatureImagePath, placement);
      if (stamped == null) return ResultFailure(FileNotFoundFailure(sourcePath));

      final name = '${p.basenameWithoutExtension(sourcePath)} signed.pdf';
      final saved = await OutputFileService.save(stamped, name);
      return Success(saved.path);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not sign this PDF: $e'));
    }
  }

  @override
  Future<Result<Uint8List>> renderPreview({
    required String sourcePath,
    required String signatureImagePath,
    required SignaturePlacement placement,
  }) async {
    pdfx.PdfDocument? document;
    try {
      final stamped = await _stamp(sourcePath, signatureImagePath, placement);
      if (stamped == null) return ResultFailure(FileNotFoundFailure(sourcePath));

      document = await pdfx.PdfDocument.openData(stamped);
      final page = await document.getPage(placement.pageNumber);
      try {
        final image = await page.render(
          width: 700,
          height: 700 * (page.height / page.width),
          format: pdfx.PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
        );
        if (image == null) {
          return const ResultFailure(UnexpectedFailure('Could not render a preview'));
        }
        return Success(image.bytes);
      } finally {
        await page.close();
      }
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not render a preview: $e'));
    } finally {
      await document?.close();
    }
  }

  Future<Uint8List?> _stamp(
    String sourcePath,
    String signatureImagePath,
    SignaturePlacement placement,
  ) async {
    final pdfFile = File(sourcePath);
    final signatureFile = File(signatureImagePath);
    if (!await pdfFile.exists() || !await signatureFile.exists()) return null;

    return SignatureEngine.stamp(
      StampSignatureRequest(
        source: await pdfFile.readAsBytes(),
        signaturePng: await signatureFile.readAsBytes(),
        pageNumber: placement.pageNumber,
        centerX: placement.centerX,
        centerY: placement.centerY,
        widthFraction: placement.widthFraction,
        rotationDegrees: placement.rotationDegrees,
      ),
    );
  }
}
