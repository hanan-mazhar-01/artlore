import '../domain/artwork.dart';
import '../domain/artwork_content.dart';
import '../domain/artwork_repository.dart';
import 'mock_catalog.dart';
import 'mock_collection_content_a.dart';
import 'mock_collection_content_b.dart';
import 'mock_collection_content_c.dart';
import 'mock_great_wave.dart';
import 'mock_starry_night.dart';

/// Serves the bundled catalogue with a small, realistic latency.
class MockArtworkRepository implements ArtworkRepository {
  const MockArtworkRepository({this.latency = Duration.zero});

  final Duration latency;

  @override
  Future<Artwork> fetchArtwork(String id) async {
    await _wait();
    final artwork = getArtwork(id);
    if (artwork == null) throw ArtworkNotFound(id);
    return artwork;
  }

  @override
  Future<List<Artwork>> fetchArtworks(List<String> ids) async {
    await _wait();
    return [for (final id in ids) ?getArtwork(id)];
  }

  @override
  Future<ArtworkContent> fetchContent(String id) async {
    await _wait();
    final dynamicContent = getDynamicContent(id);
    if (dynamicContent != null) return dynamicContent;
    return switch (id) {
      ArtworkIds.starryNight => starryNightContent,
      ArtworkIds.greatWave => greatWaveContent,
      ArtworkIds.pearlEarring => pearlEarringContent,
      ArtworkIds.kiss => kissContent,
      ArtworkIds.sunflowers => sunflowersContent,
      ArtworkIds.wanderer => wandererContent,
      ArtworkIds.milkmaid => milkmaidContent,
      ArtworkIds.sunrise => sunriseContent,
      ArtworkIds.temeraire => temeraireContent,
      ArtworkIds.grandeJatte => grandeJatteContent,
      _ => _dynamicFallback(id),
    };
  }

  static ArtworkContent _dynamicFallback(String id) {
    final a = getArtwork(id);
    if (a == null) return ArtworkContent.empty;
    return ArtworkContent(
      details: [
        ArtworkDetail(
          title: 'Composition & Focus',
          x: .5,
          y: .5,
          description: a.summary,
        ),
      ],
      story: [
        StoryChapter(
          label: 'History',
          focus: a.heroFocus,
          heading: '${a.title} in Context',
          opening:
              'Created in ${a.year}, this work represents the peak of ${a.artist}\'s '
              'masterwork during the ${a.movement} era.',
          quote: a.summary,
          quoteSource: '${a.artist}, ${a.year}',
          closing: 'Housed today at the ${a.museum} in ${a.city}.',
        ),
        StoryChapter(
          label: 'Technique',
          focus: a.heroFocus,
          heading: 'Medium and Technique',
          opening:
              'Executed in ${a.medium}, showcasing masterclass handling of light, '
              'brushwork, and surface texture.',
          quote:
              'The craftsmanship of ${a.artist} defines the ${a.movement} aesthetic.',
          quoteSource: 'Art History Archive',
          closing:
              'Measuring ${a.dimensions}, the composition balances intimate detail with monumental presence.',
        ),
        StoryChapter(
          label: 'Interpretation',
          focus: a.heroFocus,
          heading: 'Meaning & Legacy',
          opening:
              'An enduring testament to the visual heritage of ${a.movement}.',
          quote: 'Art is the lie that enables us to realize the truth.',
          quoteSource: 'Editorial Anthology',
          closing:
              'A defining pillar of the ${a.museum} permanent collection.',
        ),
      ],
    );
  }

  Future<void> _wait() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);
}
