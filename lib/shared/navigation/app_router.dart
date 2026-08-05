import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/files/presentation/screens/files_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/compress/presentation/screens/compress_screen.dart';
import '../../features/home/presentation/screens/tools_screen.dart';
import '../../features/image_to_pdf/presentation/screens/image_to_pdf_screen.dart';
import '../../features/merge/presentation/screens/merge_screen.dart';
import '../../features/pdf_to_image/presentation/screens/pdf_to_image_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/split/presentation/screens/split_screen.dart';
import '../../features/viewer/presentation/screens/viewer_screen.dart';
import 'app_shell.dart';
import 'shared_axis_page.dart';

/// Route path constants — referenced instead of raw strings so a renamed
/// route is a compile error rather than a silent 404.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String files = '/files';
  static const String tools = '/tools';
  static const String settings = '/settings';
  static const String viewer = '/viewer';
  static const String merge = '/merge';
  static const String split = '/split';
  static const String compress = '/compress';
  static const String imageToPdf = '/image-to-pdf';
  static const String pdfToImage = '/pdf-to-image';

  /// The viewer takes the document path as a query parameter so a file can
  /// be opened from any tab without threading arguments through the shell.
  static String viewerFor(String path) => '$viewer?path=${Uri.encodeQueryComponent(path)}';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.files,
              builder: (context, state) => const FilesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tools,
              builder: (context, state) => const ToolsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Sits outside the shell so the viewer is full-screen without the
    // bottom navigation bar.
    GoRoute(
      path: AppRoutes.viewer,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final path = state.uri.queryParameters['path'] ?? '';
        return sharedAxisPage(
          key: state.pageKey,
          child: ViewerScreen(path: path),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merge,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          sharedAxisPage(key: state.pageKey, child: const MergeScreen()),
    ),
    GoRoute(
      path: AppRoutes.split,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          sharedAxisPage(key: state.pageKey, child: const SplitScreen()),
    ),
    GoRoute(
      path: AppRoutes.compress,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          sharedAxisPage(key: state.pageKey, child: const CompressScreen()),
    ),
    GoRoute(
      path: AppRoutes.imageToPdf,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          sharedAxisPage(key: state.pageKey, child: const ImageToPdfScreen()),
    ),
    GoRoute(
      path: AppRoutes.pdfToImage,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          sharedAxisPage(key: state.pageKey, child: const PdfToImageScreen()),
    ),
  ],
);
