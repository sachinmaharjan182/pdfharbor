import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../data/repositories/merge_repository_impl.dart';
import '../../domain/repositories/merge_repository.dart';
import '../../domain/usecases/merge_pdfs.dart';

final mergeRepositoryProvider = Provider<MergeRepository>((ref) {
  return const MergeRepositoryImpl();
});

final mergePdfsUseCaseProvider = Provider((ref) => MergePdfs(ref.watch(mergeRepositoryProvider)));

/// One PDF queued for merging, with the display data the list row needs.
class MergeCandidate {
  const MergeCandidate({required this.path, required this.name, required this.sizeBytes});

  final String path;
  final String name;
  final int sizeBytes;
}

/// The ordered list of documents to merge. Order is the output order, so
/// reordering here is the feature's "reorder" requirement.
class MergeSelectionNotifier extends Notifier<List<MergeCandidate>> {
  @override
  List<MergeCandidate> build() => const [];

  Future<void> addPaths(Iterable<String> paths) async {
    final existing = state.map((c) => c.path).toSet();
    final additions = <MergeCandidate>[];
    for (final path in paths) {
      if (existing.contains(path)) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      additions.add(
        MergeCandidate(
          path: path,
          name: p.basename(path),
          sizeBytes: await file.length(),
        ),
      );
    }
    if (additions.isNotEmpty) state = [...state, ...additions];
  }

  void removeAt(int index) {
    final next = [...state]..removeAt(index);
    state = next;
  }

  void reorder(int oldIndex, int newIndex) {
    final next = [...state];
    // ReorderableListView reports an insertion index that assumes the item
    // is still present, so shift it down when moving an item forward.
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = next.removeAt(oldIndex);
    next.insert(target, item);
    state = next;
  }

  void clear() => state = const [];
}

final mergeSelectionProvider =
    NotifierProvider<MergeSelectionNotifier, List<MergeCandidate>>(MergeSelectionNotifier.new);
