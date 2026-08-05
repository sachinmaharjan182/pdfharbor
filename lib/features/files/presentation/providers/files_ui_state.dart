import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FileSortOrder { name, date, size }

enum FileViewMode { list, grid }

enum FileFilter { all, recent, favorites }

final fileSortOrderProvider = StateProvider<FileSortOrder>((ref) => FileSortOrder.date);
final fileViewModeProvider = StateProvider<FileViewMode>((ref) => FileViewMode.list);
final fileFilterProvider = StateProvider<FileFilter>((ref) => FileFilter.all);
final fileSearchQueryProvider = StateProvider<String>((ref) => '');
