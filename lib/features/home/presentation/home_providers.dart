import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/domain/history_entry.dart';
import '../../history/presentation/history_controller.dart';

/// Camera identifications, newest first — `null` while history loads.
final recentScansProvider = Provider<List<HistoryEntry>?>((ref) {
  final history = ref.watch(historyProvider).value;
  if (history == null) return null;
  return [
    for (final e in history)
      if (e.scanned) e,
  ].take(10).toList(growable: false);
});
