import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/core/utils/date_time_extension.dart';

void main() {
  group('relativeLabel', () {
    test('reports very recent timestamps as "Just now"', () {
      final now = DateTime.now();
      expect(now.subtract(const Duration(seconds: 5)).relativeLabel, 'Just now');
    });

    test('reports minutes for the last hour', () {
      final target = DateTime.now().subtract(const Duration(minutes: 30));
      expect(target.relativeLabel, '30m ago');
    });

    test('reports "Yesterday" for the previous calendar day', () {
      final now = DateTime.now();
      final yesterdayNoon = DateTime(now.year, now.month, now.day - 1, 12);
      // Only meaningful when "now" is past noon; otherwise the diff is <24h
      // and the hours branch legitimately wins.
      if (now.difference(yesterdayNoon).inHours >= 24) {
        expect(yesterdayNoon.relativeLabel, 'Yesterday');
      }
    });

    test('falls back to a day-month label beyond a week', () {
      final target = DateTime.now().subtract(const Duration(days: 20));
      expect(target.relativeLabel, matches(RegExp(r'^\d{1,2} [A-Z][a-z]{2}$')));
    });

    test('includes the year for dates in a different year', () {
      final target = DateTime(DateTime.now().year - 2, 3, 14);
      expect(target.relativeLabel, matches(RegExp(r'^\d{1,2} [A-Z][a-z]{2} \d{4}$')));
    });
  });
}
