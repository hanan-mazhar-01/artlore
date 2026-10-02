import 'package:flutter/foundation.dart';

import '../../artwork/domain/artwork.dart';

/// How far the visitor has travelled.
@immutable
class JourneyStats {
  const JourneyStats({
    required this.artworks,
    required this.artists,
    required this.movements,
  });

  final int artworks;
  final int artists;
  final int movements;
}

/// One axis of the visitor's taste, 0–100.
@immutable
class TasteTrait {
  const TasteTrait(this.label, this.value);

  final String label;
  final int value;
}

@immutable
class ReturningPainter {
  const ReturningPainter(this.name, this.artwork);

  final String name;
  final Artwork artwork;
}

/// The visitor's art journey and the "art personality" drawn from it.
@immutable
class ArtJourney {
  const ArtJourney({
    required this.stats,
    required this.habitNote,
    required this.personaLead,
    required this.personaEmphasis,
    required this.basis,
    required this.traits,
    required this.summary,
    required this.painters,
  });

  final JourneyStats stats;

  /// "Mostly at night, mostly under dramatic skies."
  final String habitNote;

  /// "The Night" / "Romantic".
  final String personaLead;
  final String personaEmphasis;

  /// "Drawn from 24 artworks and 3 hours of listening".
  final String basis;
  final List<TasteTrait> traits;
  final String summary;
  final List<ReturningPainter> painters;

  String get personaName => '$personaLead $personaEmphasis';
}

abstract interface class JourneyRepository {
  Future<ArtJourney> fetchJourney();
}
