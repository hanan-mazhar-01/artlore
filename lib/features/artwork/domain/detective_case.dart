import 'package:flutter/foundation.dart';

/// An Art Detective challenge: find a detail hidden in the canvas.
@immutable
class DetectiveCase {
  const DetectiveCase({
    required this.number,
    required this.total,
    required this.artworkId,
    required this.challenge,
    required this.x,
    required this.y,
    required this.foundTitle,
    required this.foundText,
    required this.hints,
  });

  final int number;
  final int total;
  final String artworkId;
  final String challenge;

  /// Target position as a fraction of the image.
  final double x;
  final double y;

  /// "Mount Fuji".
  final String foundTitle;
  final String foundText;

  /// Guidance after 0, 1–2 and 3+ misses.
  final List<String> hints;

  String hintFor(int misses) =>
      hints[misses == 0 ? 0 : (misses < 3 ? 1 : 2).clamp(0, hints.length - 1)];
}

abstract interface class DetectiveRepository {
  Future<List<DetectiveCase>> fetchCases();
}
