import 'artwork.dart';
import 'artwork_content.dart';

/// Source of catalogue data. The mock implementation serves bundled data;
/// a Firestore/CDN-backed implementation can replace it without UI changes.
abstract interface class ArtworkRepository {
  Future<Artwork> fetchArtwork(String id);

  /// Resolves [ids] in order, skipping unknown ones.
  Future<List<Artwork>> fetchArtworks(List<String> ids);

  /// Stories, details, narration and comparisons for one work.
  Future<ArtworkContent> fetchContent(String id);
}

class ArtworkNotFound implements Exception {
  const ArtworkNotFound(this.id);

  final String id;

  @override
  String toString() => 'ArtworkNotFound($id)';
}
