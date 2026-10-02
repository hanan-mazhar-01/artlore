import '../../artwork/data/mock_catalog.dart';
import '../domain/art_journey.dart';

class MockJourneyRepository implements JourneyRepository {
  const MockJourneyRepository();

  @override
  Future<ArtJourney> fetchJourney() async {
    return ArtJourney(
      stats: const JourneyStats(artworks: 24, artists: 12, movements: 6),
      habitNote: 'Mostly at night, mostly under dramatic skies.',
      personaLead: 'The Night',
      personaEmphasis: 'Romantic',
      basis: 'Drawn from 24 artworks and 3 hours of listening',
      traits: const [
        TasteTrait('Atmospheric', 82),
        TasteTrait('Emotional', 74),
        TasteTrait('Color-driven', 68),
        TasteTrait('Minimalist', 31),
      ],
      summary:
          'You seem drawn to atmospheric paintings with dramatic skies and '
          'strong emotional contrast.',
      painters: [
        ReturningPainter('Van Gogh', mockCatalog[ArtworkIds.starryNight]!),
        ReturningPainter('Friedrich', mockCatalog[ArtworkIds.wanderer]!),
        ReturningPainter('Turner', mockCatalog[ArtworkIds.temeraire]!),
      ],
    );
  }
}
