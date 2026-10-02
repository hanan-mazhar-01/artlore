import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A numbered point of interest on the canvas (Look Closer).
@immutable
class ArtworkDetail {
  const ArtworkDetail({
    required this.title,
    required this.description,
    required this.x,
    required this.y,
  });

  final String title;
  final String description;

  /// Position as a fraction of the image (0–1).
  final double x;
  final double y;
}

/// One chapter of the Deep Dive.
@immutable
class StoryChapter {
  const StoryChapter({
    required this.label,
    required this.focus,
    required this.heading,
    required this.opening,
    required this.quote,
    required this.quoteSource,
    required this.closing,
  });

  /// Tab label — "History", "Technique"…
  final String label;

  /// Which part of the canvas the header lingers on.
  final Alignment focus;
  final String heading;
  final String opening;
  final String quote;
  final String quoteSource;
  final String closing;
}

/// A length option of the narrated audio guide.
@immutable
class NarrationMode {
  const NarrationMode(this.label, this.hint, this.seconds);

  final String label;
  final String hint;
  final int seconds;
}

@immutable
class NarrationChapter {
  const NarrationChapter(this.title, this.line);

  final String title;
  final String line;
}

@immutable
class Narration {
  const Narration({
    required this.stop,
    required this.narrator,
    required this.modes,
    required this.chapters,
  });

  /// Audio guide stop number — "041".
  final String stop;
  final String narrator;
  final List<NarrationMode> modes;
  final List<NarrationChapter> chapters;
}

/// One lens of a side-by-side comparison — Color, Composition…
@immutable
class ComparisonFacet {
  const ComparisonFacet({
    required this.label,
    required this.focusA,
    required this.focusB,
    required this.textA,
    required this.textB,
    required this.verdict,
  });

  final String label;
  final Alignment focusA;
  final Alignment focusB;
  final String textA;
  final String textB;
  final String verdict;
}

@immutable
class ArtworkComparison {
  const ArtworkComparison({
    required this.otherId,
    required this.title,
    required this.subtitle,
    required this.facets,
  });

  final String otherId;

  /// "Compare with Monet".
  final String title;

  /// "Two nights, two ways of seeing".
  final String subtitle;
  final List<ComparisonFacet> facets;
}

/// Everything ArtLore can tell about a work beyond its label.
@immutable
class ArtworkContent {
  const ArtworkContent({
    this.details = const [],
    this.story = const [],
    this.narration,
    this.comparison,
  });

  static const empty = ArtworkContent();

  final List<ArtworkDetail> details;
  final List<StoryChapter> story;
  final Narration? narration;
  final ArtworkComparison? comparison;
}
