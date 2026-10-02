import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../artwork/domain/artwork.dart';
import '../../artwork/presentation/artwork_providers.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../history/domain/history_entry.dart';
import '../../history/presentation/history_controller.dart';
import '../domain/home_feed.dart';

final homeFeedProvider = FutureProvider<HomeFeed>(
  (ref) => ref.watch(homeRepositoryProvider).fetchHomeFeed(),
);

/// Camera identifications, newest first — `null` while history loads.
final recentScansProvider = Provider<List<HistoryEntry>?>((ref) {
  final history = ref.watch(historyProvider).value;
  if (history == null) return null;
  return [
    for (final e in history)
      if (e.scanned) e,
  ].take(10).toList(growable: false);
});

/// The last few works the visitor opened.
final continueExploringProvider = FutureProvider.autoDispose<List<Artwork>>((
  ref,
) {
  final ids = ref.watch(recentlyViewedProvider).take(3).toList();
  return ref.watch(artworksProvider(ArtworkIdList(ids)).future);
});
