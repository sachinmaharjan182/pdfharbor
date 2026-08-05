import 'package:file_picker/file_picker.dart';

/// Opens the system file picker filtered to PDFs.
///
/// Shared by the viewer's "Open PDF" action and the merge/split/compress
/// tools, so file-type filtering and the null/cancel contract live in one
/// place. Returns `null` when the user cancels.
abstract final class PdfPicker {
  static Future<String?> pickSingle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return result?.files.single.path;
  }

  static Future<List<String>> pickMultiple() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
    );
    if (result == null) return const [];
    return result.files.map((f) => f.path).whereType<String>().toList();
  }
}
