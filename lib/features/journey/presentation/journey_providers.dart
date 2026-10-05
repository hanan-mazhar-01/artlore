import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../artwork/data/mock_catalog.dart';
import '../../artwork/domain/artwork.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../history/presentation/history_controller.dart';
import '../domain/art_journey.dart';

final artJourneyProvider = FutureProvider<ArtJourney>((ref) async {
  final collection = await ref.watch(collectionProvider.future);
  final history = await ref.watch(historyProvider.future);

  final uniqueArtworkIds = <String>{
    ...collection.saved.map((s) => s.artworkId),
    ...history.map((h) => h.artworkId),
  };

  final artworks = uniqueArtworkIds
      .map((id) => getArtwork(id))
      .whereType<Artwork>()
      .toList();

  final artists = artworks.map((a) => a.artist).toSet();
  final movements = artworks.map((a) => a.movement).toSet();

  final stats = JourneyStats(
    artworks: artworks.length,
    artists: artists.length,
    collections: collection.galleries.length,
    movements: movements.length,
  );

  if (artworks.isEmpty) {
    return ArtJourney(
      stats: stats,
      habitNote: 'Your gallery journey is just beginning.',
      personaLead: 'The Curious',
      personaEmphasis: 'Explorer',
      basis: 'Scan artworks to reveal your art personality',
      traits: const [],
      summary:
          'Your art journey begins with your first scan. Every masterpiece '
          'you explore shapes your aesthetic fingerprint.',
      painters: const [],
    );
  }

  final movementCounts = <String, int>{};
  for (final a in artworks) {
    movementCounts[a.movement] = (movementCounts[a.movement] ?? 0) + 1;
  }
  final sortedMovements = movementCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topMovement = sortedMovements.isNotEmpty ? sortedMovements.first.key : 'Masterpiece';

  final count = artworks.length;
  final basis =
      'Drawn from $count ${count == 1 ? 'artwork' : 'artworks'} explored';

  final painters = artworks
      .take(3)
      .map((a) => ReturningPainter(a.artistShort, a))
      .toList();

  final atmosphericCount = artworks.where((a) =>
      a.movement.contains('Impression') ||
      a.movement.contains('Romantic') ||
      a.movement.contains('Dutch')).length;
  final emotionalCount = artworks.where((a) =>
      a.movement.contains('Post') ||
      a.movement.contains('Expression') ||
      a.movement.contains('Romantic')).length;
  final compositionCount = artworks.where((a) =>
      a.movement.contains('Pointillism') ||
      a.movement.contains('Realism') ||
      a.movement.contains('Dutch') ||
      a.movement.contains('Renaissance')).length;

  final atmosphericScore =
      ((atmosphericCount / count) * 60 + 35).round().clamp(20, 96);
  final emotionalScore =
      ((emotionalCount / count) * 60 + 35).round().clamp(20, 96);
  final compositionScore =
      ((compositionCount / count) * 60 + 35).round().clamp(20, 96);
  final rangeScore =
      ((artists.length / count) * 50 + (movements.length * 10))
          .round()
          .clamp(30, 98);

  final traits = [
    TasteTrait('Atmospheric', atmosphericScore),
    TasteTrait('Emotional Depth', emotionalScore),
    TasteTrait('Composition', compositionScore),
    TasteTrait('Curiosity', rangeScore),
  ]..sort((a, b) => b.value.compareTo(a.value));

  return ArtJourney(
    stats: stats,
    habitNote: 'Frequently exploring $topMovement and classic forms.',
    personaLead: 'The',
    personaEmphasis: topMovement,
    basis: basis,
    traits: traits,
    summary:
        'You are drawn to $topMovement with vivid brushwork and rich '
        'historical emotion. Your collection reflects a growing, personal vision.',
    painters: painters,
  );
});
