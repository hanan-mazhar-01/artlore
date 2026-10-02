import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../../core/media/art_image_source.dart';

/// A single work in the ArtLore catalogue.
@immutable
class Artwork {
  const Artwork({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistShort,
    required this.artistLife,
    required this.year,
    required this.medium,
    required this.dimensions,
    required this.museum,
    required this.city,
    required this.movement,
    required this.summary,
    required this.image,
    this.heroFocus = Alignment.center,
  });

  final String id;
  final String title;
  final String artist;

  /// Surname as used in editorial copy — "Van Gogh", "Vermeer".
  final String artistShort;
  final String artistLife;
  final String year;
  final String medium;
  final String dimensions;
  final String museum;
  final String city;
  final String movement;

  /// The short "Discover the story" paragraph.
  final String summary;
  final ArtImageSource image;

  /// Crop focus for full-bleed heroes (CSS object-position).
  final Alignment heroFocus;

  String get byline => '$artist · $year';

  String get metadataLine => '$year · $medium · $dimensions · $museum, $city';

  String get semanticLabel => '$title by $artist';

  @override
  bool operator ==(Object other) => other is Artwork && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
