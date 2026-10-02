import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../artwork/domain/artwork.dart';
import '../../artwork/presentation/artwork_providers.dart';
import 'collection_controller.dart';

enum CollectionGrouping { artists, movements, museums }

/// A row in the Artists / Movements / Museums views.
@immutable
class CollectionGroup {
  const CollectionGroup({
    required this.name,
    required this.subtitle,
    required this.count,
    required this.cover,
  });

  final String name;
  final String subtitle;
  final int count;
  final Artwork cover;
}

/// Saved works, newest first, resolved to artworks.
final savedArtworksProvider = FutureProvider.autoDispose<List<Artwork>>((ref) {
  final ids = ref.watch(
    collectionProvider.select((c) => c.value?.savedIds ?? const <String>[]),
  );
  return ref.watch(artworksProvider(ArtworkIdList(ids)).future);
});

/// Recently viewed works, newest first.
final recentArtworksProvider = FutureProvider.autoDispose<List<Artwork>>((ref) {
  final ids = ref.watch(recentlyViewedProvider);
  return ref.watch(artworksProvider(ArtworkIdList(ids)).future);
});

/// Saved works grouped for the list views — computed here, never in build.
final collectionGroupsProvider = FutureProvider.autoDispose
    .family<List<CollectionGroup>, CollectionGrouping>((ref, by) async {
      final artworks = await ref.watch(savedArtworksProvider.future);
      return groupArtworks(artworks, by);
    });

List<CollectionGroup> groupArtworks(
  List<Artwork> artworks,
  CollectionGrouping by,
) {
  final groups = <String, List<Artwork>>{};
  for (final a in artworks) {
    final key = switch (by) {
      CollectionGrouping.artists => a.artist,
      CollectionGrouping.movements => a.movement,
      CollectionGrouping.museums => a.museum,
    };
    (groups[key] ??= []).add(a);
  }
  final out = [
    for (final MapEntry(key: name, value: works) in groups.entries)
      CollectionGroup(
        name: name,
        count: works.length,
        cover: works.first,
        subtitle: switch (by) {
          CollectionGrouping.artists =>
            '${works.first.movement} · ${works.first.artistLife}',
          CollectionGrouping.movements => {
            for (final w in works) w.artistShort,
          }.join(', '),
          CollectionGrouping.museums => works.first.city,
        },
      ),
  ];
  out.sort((a, b) {
    final c = b.count.compareTo(a.count);
    return c != 0 ? c : a.name.compareTo(b.name);
  });
  return out;
}
