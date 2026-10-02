import 'package:flutter/foundation.dart';

import '../../artwork/domain/artwork.dart';

/// Curated content for Home. Personal sections (recent scans, continue
/// exploring, journey) come from the visitor's own history instead.
@immutable
class HomeFeed {
  const HomeFeed({required this.featured});

  /// "Take a closer look" — one editorial feature.
  final Artwork featured;
}

abstract interface class HomeRepository {
  Future<HomeFeed> fetchHomeFeed();
}
