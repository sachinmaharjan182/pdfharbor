import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/theme/app_palette.dart';
import '../../../../shared/widgets/app_card.dart';

/// Full catalogue of PDF tools. Home shows a curated subset as quick
/// actions; this screen lists everything, grouped by task, with a line of
/// description per tool.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        title: const Text('Tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          for (final group in _toolGroups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.lg, 0, AppSpacing.md),
              child: Text(
                group.title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            for (final (index, tool) in group.tools.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ToolRowCard(
                  icon: tool.icon,
                  title: tool.label,
                  subtitle: tool.description,
                  accent: tool.accent,
                  onTap: () => tool.route != null
                      ? context.push(tool.route!)
                      : context.showComingSoon(tool.label),
                ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.06, end: 0),
              ),
          ],
        ],
      ),
    );
  }

  static const List<_ToolGroup> _toolGroups = [
    _ToolGroup('ORGANIZE', [
      _Tool(
        Icons.call_merge_rounded,
        'Merge PDF',
        'Combine multiple PDFs',
        AppAccents.orange,
        route: AppRoutes.merge,
      ),
      _Tool(
        Icons.call_split_rounded,
        'Split PDF',
        'Extract pages easily',
        AppAccents.red,
        route: AppRoutes.split,
      ),
      _Tool(
        Icons.compress_rounded,
        'Compress PDF',
        'Reduce file size',
        AppAccents.amber,
        route: AppRoutes.compress,
      ),
    ]),
    _ToolGroup('CONVERT', [
      _Tool(
        Icons.image_rounded,
        'Images to PDF',
        'Convert images to PDF',
        AppAccents.violet,
        route: AppRoutes.imageToPdf,
      ),
      _Tool(
        Icons.collections_rounded,
        'PDF to Images',
        'Export pages as images',
        AppAccents.cyan,
        route: AppRoutes.pdfToImage,
      ),
      _Tool(
        Icons.document_scanner_rounded,
        'Scan Document',
        'Scan to high quality PDF',
        AppAccents.green,
        route: AppRoutes.scanner,
      ),
    ]),
    _ToolGroup('EDIT & PROTECT', [
      _Tool(
        Icons.water_drop_rounded,
        'Watermark',
        'Add text or image',
        AppAccents.cyan,
        route: AppRoutes.watermark,
      ),
      _Tool(
        Icons.draw_rounded,
        'Signature',
        'Sign your documents',
        AppAccents.pink,
        route: AppRoutes.signature,
      ),
      _Tool(
        Icons.lock_rounded,
        'Password Protect',
        'Encrypt with a password',
        AppAccents.blue,
        route: AppRoutes.security,
      ),
    ]),
  ];
}

class _ToolGroup {
  const _ToolGroup(this.title, this.tools);

  final String title;
  final List<_Tool> tools;
}

class _Tool {
  const _Tool(this.icon, this.label, this.description, this.accent, {this.route});

  final IconData icon;
  final String label;
  final String description;
  final Color accent;

  /// Null until the tool's feature phase lands; those cards show a
  /// "coming soon" snackbar instead of navigating.
  final String? route;
}
