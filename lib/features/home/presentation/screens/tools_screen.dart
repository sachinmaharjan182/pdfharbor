import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/widgets/app_card.dart';

/// Full catalogue of PDF tools. Home shows a curated subset as quick
/// actions; this screen lists everything, grouped by task.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isTablet ? 4 : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          for (final group in _toolGroups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.lg, 0, AppSpacing.md),
              child: Text(
                group.title,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.05,
              ),
              itemCount: group.tools.length,
              itemBuilder: (context, index) {
                final tool = group.tools[index];
                return ActionCard(
                  icon: tool.icon,
                  label: tool.label,
                  onTap: () => tool.route != null
                      ? context.push(tool.route!)
                      : context.showComingSoon(tool.label),
                ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.08, end: 0);
              },
            ),
          ],
        ],
      ),
    );
  }

  static const List<_ToolGroup> _toolGroups = [
    _ToolGroup('Organize', [
      _Tool(Icons.call_merge_rounded, 'Merge PDF', route: AppRoutes.merge),
      _Tool(Icons.call_split_rounded, 'Split PDF', route: AppRoutes.split),
      _Tool(Icons.compress_rounded, 'Compress PDF', route: AppRoutes.compress),
    ]),
    _ToolGroup('Convert', [
      _Tool(Icons.image_rounded, 'Image to PDF', route: AppRoutes.imageToPdf),
      _Tool(Icons.collections_rounded, 'PDF to Images', route: AppRoutes.pdfToImage),
      _Tool(Icons.document_scanner_rounded, 'Scan Document'),
    ]),
    _ToolGroup('Edit & Protect', [
      _Tool(Icons.water_drop_rounded, 'Watermark'),
      _Tool(Icons.draw_rounded, 'Signature'),
      _Tool(Icons.lock_rounded, 'Password Protect'),
    ]),
  ];
}

class _ToolGroup {
  const _ToolGroup(this.title, this.tools);

  final String title;
  final List<_Tool> tools;
}

class _Tool {
  const _Tool(this.icon, this.label, {this.route});

  final IconData icon;
  final String label;

  /// Null until the tool's feature phase lands; those cards show a
  /// "coming soon" snackbar instead of navigating.
  final String? route;
}
