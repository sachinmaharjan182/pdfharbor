import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfverse/shared/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    // Regression: an earlier version scaled the type ramp with
    // TextTheme.apply(fontSizeFactor:), which asserts every style has a
    // non-null fontSize. Material 3's base theme does not guarantee that,
    // so the app crashed on its very first build.
    test('builds without throwing, with and without a dynamic scheme', () {
      expect(AppTheme.light, returnsNormally);
      expect(AppTheme.dark, returnsNormally);

      final dynamicLight = ColorScheme.fromSeed(seedColor: const Color(0xFF00FF00));
      final dynamicDark = ColorScheme.fromSeed(
        seedColor: const Color(0xFF00FF00),
        brightness: Brightness.dark,
      );
      expect(() => AppTheme.light(dynamicLight), returnsNormally);
      expect(() => AppTheme.dark(dynamicDark), returnsNormally);
    });

    test('carries the requested brightness through', () {
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
      expect(AppTheme.light().colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
    });

    test('scales every sized text style above the Material default', () {
      final base = ThemeData(useMaterial3: true).textTheme;
      final themed = AppTheme.light().textTheme;

      // Spot-check the styles the app actually uses for headings and body.
      final pairs = <String, (TextStyle?, TextStyle?)>{
        'headlineMedium': (base.headlineMedium, themed.headlineMedium),
        'titleLarge': (base.titleLarge, themed.titleLarge),
        'bodyMedium': (base.bodyMedium, themed.bodyMedium),
        'labelSmall': (base.labelSmall, themed.labelSmall),
      };

      for (final entry in pairs.entries) {
        final (baseStyle, themedStyle) = entry.value;
        final baseSize = baseStyle?.fontSize;
        final themedSize = themedStyle?.fontSize;
        if (baseSize == null) continue;
        expect(
          themedSize,
          greaterThan(baseSize),
          reason: '${entry.key} should be scaled up',
        );
      }
    });

    test('keeps every text style slot populated', () {
      final textTheme = AppTheme.light().textTheme;
      final styles = <String, TextStyle?>{
        'displayLarge': textTheme.displayLarge,
        'displayMedium': textTheme.displayMedium,
        'displaySmall': textTheme.displaySmall,
        'headlineLarge': textTheme.headlineLarge,
        'headlineMedium': textTheme.headlineMedium,
        'headlineSmall': textTheme.headlineSmall,
        'titleLarge': textTheme.titleLarge,
        'titleMedium': textTheme.titleMedium,
        'titleSmall': textTheme.titleSmall,
        'bodyLarge': textTheme.bodyLarge,
        'bodyMedium': textTheme.bodyMedium,
        'bodySmall': textTheme.bodySmall,
        'labelLarge': textTheme.labelLarge,
        'labelMedium': textTheme.labelMedium,
        'labelSmall': textTheme.labelSmall,
      };

      for (final entry in styles.entries) {
        expect(entry.value, isNotNull, reason: '${entry.key} must not be dropped');
      }
    });
  });
}
