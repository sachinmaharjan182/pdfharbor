/// Formats timestamps into short relative or absolute labels for lists like
/// Recent Files ("2h ago", "Yesterday", "12 Mar 2026").
extension RelativeDateFormatting on DateTime {
  String get relativeLabel {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && now.day == day) return '${diff.inHours}h ago';

    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == year && yesterday.month == month && yesterday.day == day) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final sameYear = year == now.year;
    return sameYear ? '$day ${months[month - 1]}' : '$day ${months[month - 1]} $year';
  }
}
