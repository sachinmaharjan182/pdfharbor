import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Boots Hive and opens every box the app needs up front.
///
/// Entries are stored as plain `Map<String, dynamic>` rather than custom
/// `TypeAdapter`s: Hive supports maps natively, so feature repositories can
/// serialize their Freezed models with `toJson()`/`fromJson()` without any
/// generated adapter code. This sidesteps `hive_generator`'s analyzer
/// version conflict with `freezed` (see BUILD_PROGRESS.md).
abstract final class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.settings),
      Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.recentFiles),
      Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.favorites),
      Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.bookmarks),
      Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.signatures),
    ]);
  }

  static Box<Map<dynamic, dynamic>> get settingsBox =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.settings);

  static Box<Map<dynamic, dynamic>> get recentFilesBox =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.recentFiles);

  static Box<Map<dynamic, dynamic>> get favoritesBox =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.favorites);

  static Box<Map<dynamic, dynamic>> get bookmarksBox =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.bookmarks);

  static Box<Map<dynamic, dynamic>> get signaturesBox =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.signatures);
}
