import '../../artwork/data/mock_catalog.dart';
import '../domain/home_feed.dart';

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  @override
  Future<HomeFeed> fetchHomeFeed() async =>
      HomeFeed(featured: mockCatalog[ArtworkIds.greatWave]!);
}
