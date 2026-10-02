import '../../artwork/data/mock_catalog.dart';
import '../domain/photo_library.dart';

/// A camera roll of museum snapshots.
class MockPhotoLibrary implements PhotoLibrary {
  const MockPhotoLibrary();

  static const _ids = [
    ArtworkIds.kiss,
    ArtworkIds.greatWave,
    ArtworkIds.milkmaid,
    ArtworkIds.temeraire,
    ArtworkIds.sunflowers,
    ArtworkIds.grandeJatte,
  ];

  @override
  Future<List<LibraryPhoto>> recentPhotos() async => [
    for (final id in _ids) LibraryPhoto(id: id, image: mockCatalog[id]!.image),
  ];
}
