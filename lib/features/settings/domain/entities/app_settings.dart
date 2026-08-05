import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

enum DefaultPageView { continuous, horizontal }

enum DefaultCompression { low, medium, high }

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(DefaultPageView.continuous) DefaultPageView defaultPageView,
    @Default(DefaultCompression.medium) DefaultCompression defaultCompression,
  }) = _AppSettings;
}
