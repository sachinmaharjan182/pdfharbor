import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/pdf_file_entry.dart';
import '../../domain/repositories/files_repository.dart';
import '../datasources/local_pdf_datasource.dart';
import '../models/pdf_file_meta_model.dart';

class FilesRepositoryImpl implements FilesRepository {
  FilesRepositoryImpl(this._datasource, this._metaBox);

  final LocalPdfDatasource _datasource;
  final Box<Map<dynamic, dynamic>> _metaBox;

  List<PdfFileEntry>? _cachedScan;

  @override
  Future<Result<List<PdfFileEntry>>> scanDeviceForPdfs({bool forceRescan = false}) async {
    final cache = _cachedScan;
    if (!forceRescan && cache != null) return Success(cache);
    try {
      final files = await _datasource.scanForPdfFiles();
      final entries = <PdfFileEntry>[];
      for (final file in files) {
        final stat = await file.stat();
        final meta = _readMeta(file.path);
        entries.add(
          PdfFileEntry(
            path: file.path,
            name: p.basename(file.path),
            sizeBytes: stat.size,
            lastModified: stat.modified,
            lastOpened: meta?.lastOpened,
            isFavorite: meta?.isFavorite ?? false,
          ),
        );
      }
      entries.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      _cachedScan = entries;
      return Success(entries);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<PdfFileEntry>>> getRecentFiles({int limit = 10}) async {
    final scanResult = await scanDeviceForPdfs();
    return scanResult.fold(
      (entries) {
        final opened = entries.where((e) => e.lastOpened != null).toList()
          ..sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));
        return Success(opened.take(limit).toList());
      },
      (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<List<PdfFileEntry>>> getFavorites() async {
    final scanResult = await scanDeviceForPdfs();
    return scanResult.fold(
      (entries) => Success(entries.where((e) => e.isFavorite).toList()),
      (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<void>> recordOpened(String path) async {
    final now = DateTime.now();
    final existing = _readMeta(path) ?? PdfFileMetaModel(path: path);
    await _writeMeta(existing.copyWith(lastOpened: now));
    _patchCacheEntry(path, (e) => e.copyWith(lastOpened: now));
    return const Success(null);
  }

  @override
  Future<Result<void>> toggleFavorite(String path) async {
    final existing = _readMeta(path) ?? PdfFileMetaModel(path: path);
    final updated = existing.copyWith(isFavorite: !existing.isFavorite);
    await _writeMeta(updated);
    _patchCacheEntry(path, (e) => e.copyWith(isFavorite: updated.isFavorite));
    return const Success(null);
  }

  @override
  Future<Result<void>> renameFile(String path, String newName) async {
    try {
      final sanitized = newName.toLowerCase().endsWith('.pdf') ? newName : '$newName.pdf';
      final newPath = p.join(p.dirname(path), sanitized);
      await File(path).rename(newPath);

      final meta = _readMeta(path);
      await _metaBox.delete(path);
      if (meta != null) {
        await _writeMeta(meta.copyWith(path: newPath));
      }
      _cachedScan = null;
      return const Success(null);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
      await _metaBox.delete(path);
      _cachedScan?.removeWhere((e) => e.path == path);
      return const Success(null);
    } on Exception catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  PdfFileMetaModel? _readMeta(String path) {
    final raw = _metaBox.get(path);
    if (raw == null) return null;
    return PdfFileMetaModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> _writeMeta(PdfFileMetaModel meta) => _metaBox.put(meta.path, meta.toJson());

  void _patchCacheEntry(String path, PdfFileEntry Function(PdfFileEntry) patch) {
    final cache = _cachedScan;
    if (cache == null) return;
    final index = cache.indexWhere((e) => e.path == path);
    if (index == -1) return;
    cache[index] = patch(cache[index]);
  }
}
