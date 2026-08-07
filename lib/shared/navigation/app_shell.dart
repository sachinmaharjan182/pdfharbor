import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/context_extensions.dart';
import '../../core/utils/pdf_picker.dart';
import '../theme/app_palette.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';
import 'app_router.dart';

/// Bottom-navigation scaffold hosting the four top-level destinations, with
/// the design's docked centre action button between them. Each branch keeps
/// its own navigation stack via [StatefulNavigationShell].
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_Destination> _destinations = [
    _Destination(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _Destination(Icons.folder_outlined, Icons.folder_rounded, 'Files'),
    _Destination(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Tools'),
    _Destination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CentreActionButton(
        onPressed: () => _showQuickCreateSheet(context),
      ),
      bottomNavigationBar: _BottomNavBar(
        destinations: _destinations,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  void _onDestinationSelected(int index) {
    // `initialLocation: true` when re-tapping the active tab pops that
    // branch back to its root, matching platform convention.
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  /// The docked button is a shortcut to the ways a document enters the app —
  /// every entry here already exists as a tool route.
  Future<void> _showQuickCreateSheet(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      builder: (sheetContext) => const _QuickCreateSheet(),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final List<_Destination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(context, 0),
              _navItem(context, 1),
              // The gap the docked centre button sits in.
              const SizedBox(width: 72),
              _navItem(context, 2),
              _navItem(context, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index) {
    final scheme = context.colorScheme;
    final destination = destinations[index];
    final selected = index == currentIndex;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? destination.selectedIcon : destination.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              destination.label,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CentreActionButton extends StatelessWidget {
  const _CentreActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      // Lifts the button so it straddles the bar's top edge, as in the design.
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Material(
          color: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          elevation: 4,
          shadowColor: AppPalette.brand.withValues(alpha: 0.4),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Icon(Icons.add_rounded, color: scheme.onPrimary, size: 28),
          ),
        ),
      ),
    );
  }
}

class _QuickCreateSheet extends StatelessWidget {
  const _QuickCreateSheet();

  @override
  Widget build(BuildContext context) {
    // The router is captured up front: every entry closes the sheet first,
    // and this context is gone once it does.
    final router = GoRouter.of(context);

    void go(String route) {
      Navigator.of(context).pop();
      unawaited(router.push<void>(route));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, 0, AppSpacing.lg),
              child: Text('Create', style: context.textTheme.titleLarge),
            ),
            ToolRowCard(
              icon: Icons.document_scanner_rounded,
              title: 'Scan Document',
              subtitle: 'Capture pages with the camera',
              accent: AppAccents.green,
              onTap: () => go(AppRoutes.scanner),
            ),
            const SizedBox(height: AppSpacing.sm),
            ToolRowCard(
              icon: Icons.image_rounded,
              title: 'Images to PDF',
              subtitle: 'Convert photos into a document',
              accent: AppAccents.violet,
              onTap: () => go(AppRoutes.imageToPdf),
            ),
            const SizedBox(height: AppSpacing.sm),
            ToolRowCard(
              icon: Icons.call_merge_rounded,
              title: 'Merge PDFs',
              subtitle: 'Combine multiple files into one',
              accent: AppAccents.orange,
              onTap: () => go(AppRoutes.merge),
            ),
            const SizedBox(height: AppSpacing.sm),
            ToolRowCard(
              icon: Icons.folder_open_rounded,
              title: 'Open PDF',
              subtitle: 'Pick a file from your device',
              accent: AppAccents.blue,
              onTap: () async {
                Navigator.of(context).pop();
                final path = await PdfPicker.pickSingle();
                if (path == null) return;
                await router.push(AppRoutes.viewerFor(path));
              },
            ),
          ],
        ),
      ),
    );
  }
}
