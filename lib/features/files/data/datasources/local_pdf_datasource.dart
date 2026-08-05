import 'dart:io';

/// Recursively scans device storage for `.pdf` files.
///
/// Requires broad storage access (`MANAGE_EXTERNAL_STORAGE` on Android
/// 11+) to see files outside the app's own sandbox; directories that
/// aren't readable are skipped rather than failing the whole scan.
class LocalPdfDatasource {
  const LocalPdfDatasource();

  static const String _rootPath = '/storage/emulated/0';
  static const int _maxDepth = 8;

  Future<List<File>> scanForPdfFiles() async {
    final found = <String, File>{};
    final root = Directory(_rootPath);
    if (await root.exists()) {
      await _scanDirectory(root, found, depth: 0);
    }
    return found.values.toList();
  }

  Future<void> _scanDirectory(
    Directory dir,
    Map<String, File> found, {
    required int depth,
  }) async {
    if (depth > _maxDepth) return;
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          found[entity.path] = entity;
        } else if (entity is Directory && !_isHiddenOrRestricted(entity.path)) {
          await _scanDirectory(entity, found, depth: depth + 1);
        }
      }
    } on FileSystemException {
      // No permission to read this directory — skip it, keep scanning siblings.
    }
  }

  bool _isHiddenOrRestricted(String path) {
    final segment = path.split(Platform.pathSeparator).last;
    if (segment.startsWith('.')) return true;
    // Android/data and Android/obb are OS-restricted even with broad
    // storage access; walking into them just throws on every file.
    return segment == 'Android';
  }
}
