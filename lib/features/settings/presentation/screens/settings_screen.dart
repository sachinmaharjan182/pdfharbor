import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          _SettingsGroup(
            title: 'Appearance',
            children: [
              _SettingsTile(
                title: 'Theme',
                value: _themeModeLabel(settings.themeMode),
                onTap: () => _showThemePicker(context, ref, settings.themeMode),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsGroup(
            title: 'Defaults',
            children: [
              _SettingsTile(
                title: 'Default page view',
                value: _pageViewLabel(settings.defaultPageView),
                onTap: () => _showPageViewPicker(context, ref, settings.defaultPageView),
              ),
              _SettingsTile(
                title: 'Default compression',
                value: _compressionLabel(settings.defaultCompression),
                onTap: () => _showCompressionPicker(context, ref, settings.defaultCompression),
              ),
              _SettingsTile(
                title: 'App language',
                value: 'English',
                onTap: () => context.showComingSoon('Additional languages'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsGroup(
            title: 'About',
            children: [
              _SettingsTile(
                title: 'Rate PDFHarbor',
                onTap: () => _openUrl(
                  context,
                  'https://play.google.com/store/apps/details?id=com.pdfverse.app',
                ),
              ),
              _SettingsTile(
                title: 'Privacy Policy',
                onTap: () => _openUrl(context, 'https://pdfverse.app/privacy'),
              ),
              _SettingsTile(
                title: 'About PDFHarbor',
                value: packageInfo.maybeWhen(
                  data: (info) => 'Version ${info.version}',
                  orElse: () => 'Loading…',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  static String _pageViewLabel(DefaultPageView view) => switch (view) {
        DefaultPageView.continuous => 'Continuous scrolling',
        DefaultPageView.horizontal => 'Horizontal pages',
      };

  static String _compressionLabel(DefaultCompression compression) => switch (compression) {
        DefaultCompression.low => 'Low — best quality',
        DefaultCompression.medium => 'Medium — balanced',
        DefaultCompression.high => 'High — smallest size',
      };

  Future<void> _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
    return showAppBottomSheet<void>(
      context,
      builder: (sheetContext) => _OptionSheet<ThemeMode>(
        title: 'Theme',
        current: current,
        options: ThemeMode.values,
        labelBuilder: _themeModeLabel,
        onSelected: (mode) => ref.read(settingsProvider.notifier).setThemeMode(mode),
      ),
    );
  }

  Future<void> _showPageViewPicker(BuildContext context, WidgetRef ref, DefaultPageView current) {
    return showAppBottomSheet<void>(
      context,
      builder: (sheetContext) => _OptionSheet<DefaultPageView>(
        title: 'Default page view',
        current: current,
        options: DefaultPageView.values,
        labelBuilder: _pageViewLabel,
        onSelected: (value) => ref.read(settingsProvider.notifier).setDefaultPageView(value),
      ),
    );
  }

  Future<void> _showCompressionPicker(
    BuildContext context,
    WidgetRef ref,
    DefaultCompression current,
  ) {
    return showAppBottomSheet<void>(
      context,
      builder: (sheetContext) => _OptionSheet<DefaultCompression>(
        title: 'Default compression',
        current: current,
        options: DefaultCompression.values,
        labelBuilder: _compressionLabel,
        onSelected: (value) => ref.read(settingsProvider.notifier).setDefaultCompression(value),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      context.showSnackBar('Could not open the link', isError: true);
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, 0, AppSpacing.md),
          child: Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0) const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One settings row: label on the left, current value in muted text on the
/// right, chevron only when the row actually opens something.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.value,
    this.onTap,
  });

  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (value case final label?)
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded, size: 20, color: scheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic single-choice bottom sheet, so theme/page-view/compression
/// pickers all share one implementation.
class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.current,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
  });

  final String title;
  final T current;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.sm, AppSpacing.xxl, AppSpacing.md),
            child: Text(title, style: context.textTheme.titleLarge),
          ),
          RadioGroup<T>(
            groupValue: current,
            onChanged: (value) {
              if (value != null) onSelected(value);
              Navigator.of(context).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  RadioListTile<T>(value: option, title: Text(labelBuilder(option))),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
