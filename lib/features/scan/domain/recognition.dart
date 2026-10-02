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
