import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../collections/presentation/collection_controller.dart';
import '../domain/history_entry.dart';

/// The visitor's timeline of scanned and explored works.
final historyProvider =
    AsyncNotifierProvider<HistoryController, List<HistoryEntry>>(
      HistoryController.new,
    );

class HistoryController extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() {
    ref.watch(authStateProvider);
    return ref.watch(historyRepositoryProvider).fetchHistory();
  }

  /// Records a fresh identification at the top of the timeline.
  Future<void> recordScan({
    required String artworkId,
    required String where,
  }) async {
    final entry = HistoryEntry(
      id: 'scan-${DateTime.now().microsecondsSinceEpoch}',
      artworkId: artworkId,
      at: DateTime.now(),
      where: where,
      activity: 'Identified · story unlocked',
    );
    final current = state.value ?? const [];
    state = AsyncData([entry, ...current]);
    await ref.read(historyRepositoryProvider).add(entry);
  }
}

/// Everything the visitor has done, for "Your history": every scan, plus any
/// saved work that has no scan of its own (saved from a painting's page, say),
/// so nothing they found is missing. Newest first; such saved works follow
/// the last dated entry.
final fullHistoryProvider = Provider<AsyncValue<List<HistoryEntry>>>((ref) {
  final history = ref.watch(historyProvider);
  final collection = ref.watch(collectionProvider).value;
  return history.whenData((entries) {
    if (collection == null || collection.saved.isEmpty) return entries;
    final known = {for (final e in entries) e.artworkId};
    final galleryName = {for (final g in collection.galleries) g.id: g.name};
    var when = entries.isEmpty
        ? DateTime.now()
        : entries.last.at.subtract(const Duration(minutes: 1));
    final extra = <HistoryEntry>[];
    for (final w in collection.saved) {
      if (!known.add(w.artworkId)) continue;
      extra.add(
        HistoryEntry(
          id: 'saved-${w.artworkId}',
          artworkId: w.artworkId,
          at: when,
          where: 'In your collection',
          activity: 'Saved to ${galleryName[w.galleryId] ?? 'Favorites'}',
          scanned: false,
        ),
      );
      when = when.subtract(const Duration(minutes: 1));
    }
    return [...entries, ...extra];
  });
});
