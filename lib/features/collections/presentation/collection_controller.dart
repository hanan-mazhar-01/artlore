import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
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
  Future<CollectionSnapshot> build() {
    ref.watch(authStateProvider);
    return ref.watch(collectionRepositoryProvider).load();
  }

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

  /// Generates and selects the gallery immediately — persistence to the
  /// repository (a network call) happens in the background, so the visitor
  /// can select and save into it right away instead of racing a save
  /// against the gallery not existing yet in local state.
  Future<Gallery> createGallery(String name) async {
    final current = state.value;
    final customCount = current?.galleries.where((g) => g.id != 'favorites').length ?? 0;
    if (customCount >= maxCustomGalleries) {
      throw StateError('Maximum $maxCustomGalleries custom galleries allowed.');
    }
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final gallery = Gallery(id: '$slug-${DateTime.now().microsecondsSinceEpoch}', name: name);
    if (current != null) {
      state = AsyncData(
        current.copyWith(galleries: [...current.galleries, gallery]),
      );
    }
    unawaited(
      _repo.createGallery(gallery).catchError((Object e) {
        debugPrint('createGallery persistence error: $e');
      }),
    );
    return gallery;
  }

  Future<void> deleteGallery(String galleryId) async {
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          galleries: current.galleries.where((g) => g.id != galleryId).toList(),
          saved: current.saved.where((s) => s.galleryId != galleryId).toList(),
        ),
      );
    }
    await _repo.deleteGallery(galleryId);
  }
}

/// Recently viewed artworks, newest first.
final recentlyViewedProvider =
    NotifierProvider<RecentlyViewedController, List<String>>(
      RecentlyViewedController.new,
    );

class RecentlyViewedController extends Notifier<List<String>> {
  static const _baseKey = 'artlore.recently_viewed';
  static const _limit = 24;

  String get _currentKey {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null && user.uid.isNotEmpty) {
      return '$_baseKey.${user.uid}';
    }
    return '$_baseKey.guest';
  }

  @override
  List<String> build() {
    ref.watch(authStateProvider);
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      return prefs.getStringList(_currentKey) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  void markViewed(String artworkId) {
    if (state.isNotEmpty && state.first == artworkId) return;
    final updated = [
      artworkId,
      ...state.where((id) => id != artworkId),
    ].take(_limit).toList(growable: false);
    state = updated;
    try {
      ref.read(sharedPreferencesProvider).setStringList(_currentKey, updated);
    } catch (_) {}
  }

  Future<void> clear() async {
    state = const [];
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove(_currentKey);
      await prefs.remove('$_baseKey.guest');
      await prefs.remove(_baseKey);
      for (final k in prefs.getKeys()) {
        if (k.startsWith(_baseKey)) {
          await prefs.remove(k);
        }
      }
    } catch (_) {}
  }
}

