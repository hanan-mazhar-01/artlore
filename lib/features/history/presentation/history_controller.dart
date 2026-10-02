import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/history_entry.dart';

/// The visitor's timeline of scanned and explored works.
final historyProvider =
    AsyncNotifierProvider<HistoryController, List<HistoryEntry>>(
      HistoryController.new,
    );

class HistoryController extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() =>
      ref.watch(historyRepositoryProvider).fetchHistory();

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
