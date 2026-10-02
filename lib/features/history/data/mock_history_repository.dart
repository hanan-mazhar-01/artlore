import '../../artwork/data/mock_catalog.dart';
import '../domain/history_entry.dart';

/// In-memory history seeded with the design's timeline.
class MockHistoryRepository implements HistoryRepository {
  MockHistoryRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  late final List<HistoryEntry> _entries = _seed(_clock());

  @override
  Future<List<HistoryEntry>> fetchHistory() async =>
      List.unmodifiable(_entries);

  @override
  Future<void> add(HistoryEntry entry) async => _entries.insert(0, entry);

  static List<HistoryEntry> _seed(DateTime now) {
    return [
      HistoryEntry(
        id: 'h1',
        artworkId: ArtworkIds.starryNight,
        at: now.subtract(const Duration(hours: 2)),
        where: 'Scanned at MoMA, New York',
        activity: 'Listened 4 min · Explored 4 details',
      ),
      HistoryEntry(
        id: 'h2',
        artworkId: ArtworkIds.greatWave,
        at: now.subtract(const Duration(days: 1, hours: 3)),
        where: 'Scanned from a print',
        activity: 'Art Detective · case solved',
      ),
      HistoryEntry(
        id: 'h3',
        artworkId: ArtworkIds.pearlEarring,
        at: now.subtract(const Duration(days: 4)),
        where: 'Mauritshuis, The Hague',
        activity: 'Look Closer · saved to Favorites',
      ),
      HistoryEntry(
        id: 'h4',
        artworkId: ArtworkIds.sunrise,
        at: now.subtract(const Duration(days: 7)),
        where: 'Discovered in recommendations',
        activity: 'Compared with Van Gogh',
        scanned: false,
      ),
    ];
  }
}
