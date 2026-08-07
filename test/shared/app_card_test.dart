import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/shared/widgets/app_card.dart';
import 'package:pdfharbor/shared/theme/app_theme.dart';

/// Pumps [child] inside the real app theme, so theme-dependent assertions
/// fire here rather than on device.
Future<void> _pumpThemed(WidgetTester tester, Widget child, {Brightness? brightness}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('AppCard', () {
    // Regression: AppCard once passed both `shape` and `borderRadius` to
    // Material, which asserts they are never both set. It compiled and
    // only blew up when the widget actually built.
    testWidgets('builds in both light and dark themes', (tester) async {
      for (final brightness in Brightness.values) {
        await _pumpThemed(
          tester,
          const AppCard(child: Text('content')),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull, reason: 'failed in $brightness');
        expect(find.text('content'), findsOneWidget);
      }
    });

    testWidgets('invokes onTap when pressed', (tester) async {
      var taps = 0;
      await _pumpThemed(
        tester,
        AppCard(onTap: () => taps++, child: const Text('tap me')),
      );
      await tester.tap(find.text('tap me'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('honours a custom border radius without asserting', (tester) async {
      await _pumpThemed(
        tester,
        AppCard(
          borderRadius: BorderRadius.circular(4),
          child: const Text('rounded'),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('ActionCard', () {
    testWidgets('renders its icon and label and responds to taps', (tester) async {
      var taps = 0;
      await _pumpThemed(
        tester,
        ActionCard(
          icon: Icons.call_merge_rounded,
          label: 'Merge PDF',
          onTap: () => taps++,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Merge PDF'), findsOneWidget);
      expect(find.byIcon(Icons.call_merge_rounded), findsOneWidget);

      await tester.tap(find.text('Merge PDF'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('builds in dark theme', (tester) async {
      await _pumpThemed(
        tester,
        ActionCard(icon: Icons.lock_rounded, label: 'Protect', onTap: () {}),
        brightness: Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
