/// Formats a byte count into a short human-readable string, e.g. `1.4 MB`.
extension FileSizeFormatting on int {
  String get readableFileSize {
    if (this <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final decimals = unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }
}
