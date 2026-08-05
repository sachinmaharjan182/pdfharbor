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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          _SettingsGroup(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.brightness_6_rounded,
                title: 'Theme',
                subtitle: _themeModeLabel(settings.themeMode),
                onTap: () => _showThemePicker(context, ref, settings.themeMode),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'Defaults',
            children: [
              _SettingsTile(
                icon: Icons.auto_stories_rounded,
                title: 'Default page view',
                subtitle: _pageViewLabel(settings.defaultPageView),
                onTap: () => _showPageViewPicker(context, ref, settings.defaultPageView),
              ),
              _SettingsTile(
                icon: Icons.compress_rounded,
                title: 'Default compression',
                subtitle: _compressionLabel(settings.defaultCompression),
                onTap: () => _showCompressionPicker(context, ref, settings.defaultCompression),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'App language',
                subtitle: 'English (device default)',
                onTap: () => context.showComingSoon('Additional languages'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.star_rounded,
                title: 'Rate PDFverse',
                subtitle: 'Let us know how we are doing',
                onTap: () => _openUrl(
                  context,
                  'https://play.google.com/store/apps/details?id=com.pdfverse.app',
                ),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                onTap: () => _openUrl(context, 'https://pdfverse.app/privacy'),
              ),
              _SettingsTile(
                icon: Icons.info_rounded,
                title: 'Version',
                subtitle: packageInfo.maybeWhen(
                  data: (info) => '${info.version} (${info.buildNumber})',
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, 0, AppSpacing.md),
          child: Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppCard(padding: EdgeInsets.zero, child: Column(children: children)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorScheme.onSurfaceVariant),
      title: Text(title, style: context.textTheme.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
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
