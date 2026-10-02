import '../domain/detective_case.dart';
import 'mock_catalog.dart';

class MockDetectiveRepository implements DetectiveRepository {
  const MockDetectiveRepository();

  @override
  Future<List<DetectiveCase>> fetchCases() async => const [
    DetectiveCase(
      number: 3,
      total: 5,
      artworkId: ArtworkIds.greatWave,
      challenge: 'Find the sacred mountain hiding beneath the wave.',
      x: .63,
      y: .68,
      foundTitle: 'Mount Fuji',
      foundText:
          'Hokusai shrinks Japan\'s most sacred peak to the size of a wave\'s '
          'spray — the eternal mountain, briefly at the mercy of a passing '
          'moment.',
      hints: [
        'Tap the painting where you think it hides.',
        'Not quite. It is smaller than you think.',
        'Look low — framed by the hollow of the great wave.',
      ],
    ),
    DetectiveCase(
      number: 4,
      total: 5,
      artworkId: ArtworkIds.starryNight,
      challenge: 'Find the steeple that belongs to another country.',
      x: .57,
      y: .66,
      foundTitle: 'The village steeple',
      foundText:
          'Sharp and northern, the spire is more Dutch than Provençal — Van '
          'Gogh quietly painting home into a southern French village.',
      hints: [
        'Tap the painting where you think it hides.',
        'Not quite. Look below the swirling sky.',
        'It rises from the sleeping village, right of the cypress.',
      ],
    ),
  ];
}
