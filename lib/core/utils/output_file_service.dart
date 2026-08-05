import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Writes tool output (merged/split/compressed PDFs, exported images) to a
/// user-visible folder.
///
/// Prefers the public `Documents/PDFverse` directory so results survive
/// uninstall and are reachable from other apps; falls back to app-private
/// storage when that isn't writable.
abstract final class OutputFileService {
  static const String _publicDir = '/storage/emulated/0/Documents/PDFverse';

  static Future<Directory> outputDirectory() async {
    final public = Directory(_publicDir);
    try {
      if (!await public.exists()) await public.create(recursive: true);
      return public;
    } on FileSystemException {
      final fallback = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(fallback.path, 'PDFverse'));
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
  }

  /// Saves [bytes] as [fileName], appending ` (2)`, ` (3)`… if that name is
  /// taken so a tool run never silently overwrites an earlier result.
  static Future<File> save(Uint8List bytes, String fileName) async {
    final dir = await outputDirectory();
    final file = File(p.join(dir.path, await _uniqueName(dir, fileName)));
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<String> _uniqueName(Directory dir, String fileName) async {
    final extension = p.extension(fileName);
    final stem = p.basenameWithoutExtension(fileName);

    var candidate = fileName;
    var counter = 2;
    while (await File(p.join(dir.path, candidate)).exists()) {
      candidate = '$stem ($counter)$extension';
      counter++;
    }
    return candidate;
  }
}
