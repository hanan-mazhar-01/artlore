import '../../artwork/data/mock_catalog.dart';
import '../domain/recognition.dart';

class MockRecognitionRepository implements RecognitionRepository {
  const MockRecognitionRepository({
    this.latency = const Duration(milliseconds: 1500),
  });

  final Duration latency;

  @override
  Future<Identification> identify(CapturedFrame frame) async {
    await Future<void>.delayed(latency);
    // A library photo of a known work is "recognised" as that work.
    final picked = frame.photoId;
    if (picked != null && mockCatalog.containsKey(picked)) {
      return Identification(artworkId: picked, where: 'Scanned from a photo');
    }
    return const Identification(
      artworkId: ArtworkIds.starryNight,
      where: 'Scanned at MoMA, New York',
    );
  }
}
