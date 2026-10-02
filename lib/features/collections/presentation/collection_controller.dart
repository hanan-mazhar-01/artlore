import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../artwork/data/mock_catalog.dart';
import '../domain/collection_models.dart';

/// The visitor's galleries and saved works.
final collectionProvider =
    AsyncNotifierProvider<CollectionController, CollectionSnapshot>(
      CollectionController.new,
    );

/// Whether one artwork is saved — widgets watch just this bit.
final isSavedProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(
    collectionProvider.select((c) => c.value?.isSaved(id) ?? false),
  ),
);

class CollectionController extends AsyncNotifier<CollectionSnapshot> {
  CollectionRepository get _repo => ref.read(collectionRepositoryProvider);

  @override
  Future<CollectionSnapshot> build() =>
      ref.watch(collectionRepositoryProvider).load();

  /// Optimistically hangs the work, then syncs with the repository.
  Future<void> save(String artworkId, String galleryId) async {
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          saved: [
            SavedWork(artworkId: artworkId, galleryId: galleryId),
            ...current.saved.where((s) => s.artworkId != artworkId),
          ],
        ),
      );
    }
    await _repo.save(artworkId, galleryId);
  }

  Future<void> remove(String artworkId) async {
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          saved: current.saved.where((s) => s.artworkId != artworkId).toList(),
        ),
      );
    }
    await _repo.remove(artworkId);
  }

  Future<Gallery> createGallery(String name) async {
    final gallery = await _repo.createGallery(name);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(galleries: [...current.galleries, gallery]),
      );
    }
    return gallery;
  }
}

/// Recently viewed artworks, newest first.
final recentlyViewedProvider =
    NotifierProvider<RecentlyViewedController, List<String>>(
      RecentlyViewedController.new,
    );

class RecentlyViewedController extends Notifier<List<String>> {
  static const _limit = 24;

  @override
  List<String> build() => const [
    ArtworkIds.starryNight,
    ArtworkIds.greatWave,
    ArtworkIds.pearlEarring,
    ArtworkIds.sunrise,
    ArtworkIds.grandeJatte,
    ArtworkIds.temeraire,
  ];

  void markViewed(String artworkId) {
    if (state.isNotEmpty && state.first == artworkId) return;
    state = [
      artworkId,
      ...state.where((id) => id != artworkId),
    ].take(_limit).toList(growable: false);
  }
}
