import '../../artwork/data/mock_catalog.dart';
import '../domain/collection_models.dart';

/// In-memory collection standing in for the visitor's cloud library.
class MockCollectionRepository implements CollectionRepository {
  final _galleries = <Gallery>[
    const Gallery(id: 'favorites', name: 'Favorites'),
    const Gallery(id: 'night-skies', name: 'Night Skies'),
    const Gallery(id: 'van-gogh', name: 'Van Gogh'),
  ];

  final _saved = <SavedWork>[
    const SavedWork(artworkId: ArtworkIds.pearlEarring, galleryId: 'favorites'),
    const SavedWork(artworkId: ArtworkIds.kiss, galleryId: 'favorites'),
    const SavedWork(artworkId: ArtworkIds.sunflowers, galleryId: 'van-gogh'),
    const SavedWork(artworkId: ArtworkIds.wanderer, galleryId: 'night-skies'),
    const SavedWork(artworkId: ArtworkIds.greatWave, galleryId: 'favorites'),
    const SavedWork(artworkId: ArtworkIds.milkmaid, galleryId: 'favorites'),
    const SavedWork(artworkId: ArtworkIds.sunrise, galleryId: 'night-skies'),
  ];

  @override
  Future<CollectionSnapshot> load() async => CollectionSnapshot(
    galleries: List.unmodifiable(_galleries),
    saved: List.unmodifiable(_saved),
  );

  @override
  Future<void> save(String artworkId, String galleryId) async {
    _saved
      ..removeWhere((s) => s.artworkId == artworkId)
      ..insert(0, SavedWork(artworkId: artworkId, galleryId: galleryId));
  }

  @override
  Future<void> remove(String artworkId) async {
    _saved.removeWhere((s) => s.artworkId == artworkId);
  }

  @override
  Future<Gallery> createGallery(String name) async {
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final gallery = Gallery(
      id: '$slug-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
    );
    _galleries.add(gallery);
    return gallery;
  }
}
