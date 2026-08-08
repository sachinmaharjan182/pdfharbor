import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'core/constants/app_constants.dart';
import 'core/hive/hive_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'shared/navigation/app_router.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _useAndroidPhotoPicker();
  await HiveService.init();
  runApp(const ProviderScope(child: PdfHarborApp()));
}

/// Routes gallery picking through the Android Photo Picker.
///
/// `useAndroidPhotoPicker` still defaults to false in image_picker_android, and
/// when it is off the plugin launches `ACTION_GET_CONTENT` instead — which is
/// what got the app rejected, since Play requires system pickers unless they
/// can't cover core functionality. Keep this in place: dropping it silently
/// reintroduces the violation with no compile-time signal.
void _useAndroidPhotoPicker() {
  final picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) {
    picker.useAndroidPhotoPicker = true;
  }
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
