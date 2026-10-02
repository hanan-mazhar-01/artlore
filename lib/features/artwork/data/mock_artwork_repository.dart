import '../domain/artwork.dart';
import '../domain/artwork_content.dart';
import '../domain/artwork_repository.dart';
import 'mock_catalog.dart';
import 'mock_great_wave.dart';
import 'mock_starry_night.dart';

/// Serves the bundled catalogue with a small, realistic latency.
class MockArtworkRepository implements ArtworkRepository {
  const MockArtworkRepository({this.latency = Duration.zero});

  final Duration latency;

  @override
  Future<Artwork> fetchArtwork(String id) async {
    await _wait();
    final artwork = mockCatalog[id];
    if (artwork == null) throw ArtworkNotFound(id);
    return artwork;
  }

  @override
  Future<List<Artwork>> fetchArtworks(List<String> ids) async {
    await _wait();
    return [for (final id in ids) ?mockCatalog[id]];
  }

  @override
  Future<ArtworkContent> fetchContent(String id) async {
    await _wait();
    return switch (id) {
      ArtworkIds.starryNight => starryNightContent,
      ArtworkIds.greatWave => greatWaveContent,
      _ => ArtworkContent.empty,
    };
  }

  Future<void> _wait() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);
}
