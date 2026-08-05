import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  static const _key = 'app_settings';

  @override
  AppSettings load() {
    final raw = _box.get(_key);
    if (raw == null) return const AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values.byName((raw['themeMode'] as String?) ?? ThemeMode.system.name),
      defaultPageView: DefaultPageView.values
          .byName((raw['defaultPageView'] as String?) ?? DefaultPageView.continuous.name),
      defaultCompression: DefaultCompression.values
          .byName((raw['defaultCompression'] as String?) ?? DefaultCompression.medium.name),
    );
  }

  @override
  Future<void> save(AppSettings settings) {
    return _box.put(_key, {
      'themeMode': settings.themeMode.name,
      'defaultPageView': settings.defaultPageView.name,
      'defaultCompression': settings.defaultCompression.name,
    });
  }
}
