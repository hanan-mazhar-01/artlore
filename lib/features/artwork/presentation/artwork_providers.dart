import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/artwork.dart';
import '../domain/artwork_content.dart';

/// One artwork by id. Auto-disposed when no screen shows it.
final artworkProvider = FutureProvider.autoDispose.family<Artwork, String>(
  (ref, id) => ref.watch(artworkRepositoryProvider).fetchArtwork(id),
);

/// Editorial content (story, details, narration…) for one artwork.
final artworkContentProvider = FutureProvider.autoDispose
    .family<ArtworkContent, String>(
      (ref, id) => ref.watch(artworkRepositoryProvider).fetchContent(id),
    );

/// Several artworks resolved in order — for rails and grids.
final artworksProvider = FutureProvider.autoDispose
    .family<List<Artwork>, ArtworkIdList>(
      (ref, ids) => ref.watch(artworkRepositoryProvider).fetchArtworks(ids.ids),
    );

/// Value-equal id list so `artworksProvider` families are cached correctly.
class ArtworkIdList {
  const ArtworkIdList(this.ids);

  final List<String> ids;

  @override
  bool operator ==(Object other) =>
      other is ArtworkIdList &&
      other.ids.length == ids.length &&
      _same(other.ids, ids);

  static bool _same(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(ids);
}
