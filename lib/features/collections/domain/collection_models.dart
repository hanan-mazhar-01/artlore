import 'package:flutter/foundation.dart';

/// A named wall in the visitor's private museum.
@immutable
class Gallery {
  const Gallery({required this.id, required this.name});

  final String id;
  final String name;
}

/// An artwork hung in one of the visitor's galleries.
@immutable
class SavedWork {
  const SavedWork({required this.artworkId, required this.galleryId});

  final String artworkId;
  final String galleryId;
}

/// The visitor's whole collection. Saved works are newest first.
@immutable
class CollectionSnapshot {
  const CollectionSnapshot({required this.galleries, required this.saved});

  final List<Gallery> galleries;
  final List<SavedWork> saved;

  bool isSaved(String artworkId) => saved.any((s) => s.artworkId == artworkId);

  String? galleryOf(String artworkId) {
    for (final s in saved) {
      if (s.artworkId == artworkId) return s.galleryId;
    }
    return null;
  }

  int countIn(String galleryId) =>
      saved.where((s) => s.galleryId == galleryId).length;

  List<String> get savedIds => [for (final s in saved) s.artworkId];

  CollectionSnapshot copyWith({
    List<Gallery>? galleries,
    List<SavedWork>? saved,
  }) {
    return CollectionSnapshot(
      galleries: galleries ?? this.galleries,
      saved: saved ?? this.saved,
    );
  }
}

abstract interface class CollectionRepository {
  Future<CollectionSnapshot> load();

  /// Hangs [artworkId] in [galleryId], moving it if already saved.
  Future<void> save(String artworkId, String galleryId);
  Future<void> remove(String artworkId);
  Future<Gallery> createGallery(String name);
}
