import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/hive/hive_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'shared/navigation/app_router.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: PdfHarborApp()));
}

class PdfHarborApp extends ConsumerWidget {
  const PdfHarborApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));

    // No `DynamicColorBuilder` here on purpose: PDFHarbor uses its own brand
    // palette, and the platform's wallpaper colors would repaint it.
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
