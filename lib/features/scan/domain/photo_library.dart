import 'package:flutter/foundation.dart';

import '../../../core/media/art_image_source.dart';

/// A picture in the visitor's photo library.
@immutable
class LibraryPhoto {
  const LibraryPhoto({required this.id, required this.image});

  final String id;
  final ArtImageSource image;
}

/// The device photo library. Mocked today; `image_picker` or PhotoKit
/// slots in behind this later.
abstract interface class PhotoLibrary {
  Future<List<LibraryPhoto>> recentPhotos();
}
