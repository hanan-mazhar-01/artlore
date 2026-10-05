import 'package:flutter/foundation.dart';

/// A frame handed to recognition: camera bytes, or a photo from the
/// library. Empty in the mock apart from [photoId].
@immutable
class CapturedFrame {
  const CapturedFrame({this.bytes, this.photoId});

  final Uint8List? bytes;

  /// Library photo the visitor picked (Scan from Photos).
  final String? photoId;
}

/// Result of identifying an artwork.
@immutable
class Identification {
  const Identification({required this.artworkId, required this.where});

  final String artworkId;

  /// Where the scan happened — "Scanned at MoMA, New York".
  final String where;
}

/// Artwork recognition. The mock always "finds" The Starry Night; a
/// Gemini/vision-backed implementation replaces it later.
abstract interface class RecognitionRepository {
  Future<Identification> identify(CapturedFrame frame);
}

/// Thrown when recognition fails or artwork cannot be identified.
class RecognitionFailedException implements Exception {
  const RecognitionFailedException([
    this.message = 'Artwork could not be recognized.',
  ]);

  final String message;

  @override
  String toString() => 'RecognitionFailedException: $message';
}

/// Thrown when the photo clearly isn't of a painting or artwork at all —
/// ArtLore only identifies artworks and tells their stories, so this is
/// surfaced to the visitor as a distinct, friendlier message rather than a
/// generic recognition failure.
class UnsupportedSubjectException implements Exception {
  const UnsupportedSubjectException([this.description]);

  /// What the photo actually appears to show, e.g. "a person" or "a coffee
  /// mug" — may be empty if the model didn't say.
  final String? description;

  @override
  String toString() => 'UnsupportedSubjectException: $description';
}
