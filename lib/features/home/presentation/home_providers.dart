import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../artwork/domain/artwork.dart';
import '../../artwork/presentation/artwork_providers.dart';
import '../../collections/presentation/collection_views.dart';
import '../../history/domain/history_entry.dart';
import '../../history/presentation/history_controller.dart';

/// Camera identifications, newest first — `null` while history loads.
final recentScansProvider = Provider<List<HistoryEntry>?>((ref) {
  final history = ref.watch(historyProvider).value;
  if (history == null) return null;
  return [
    for (final e in history)
      if (e.scanned) e,
  ].take(10).toList(growable: false);
});

/// What Home search looks through: every scanned work and every saved work.
typedef HomeSearchPool = ({List<Artwork> scans, List<Artwork> saved});

final homeSearchPoolProvider = Provider<HomeSearchPool>((ref) {
  final history = ref.watch(historyProvider).value ?? const <HistoryEntry>[];
  final seen = <String>{};
  final scans = <Artwork>[];
  for (final e in history) {
    if (!e.scanned) continue;
    final a = ref.watch(artworkProvider(e.artworkId)).value;
    if (a != null && seen.add(a.id)) scans.add(a);
  }
  final saved = ref.watch(savedArtworksProvider).value ?? const <Artwork>[];
  return (scans: scans, saved: saved);
});

/// Thumbnail of the newest photo in the phone's library, for the "Scan from
/// Photos" card. `null` when access is declined, the library is empty, or
/// there is no photo library (web).
final latestPhotoProvider = FutureProvider.autoDispose<Uint8List?>((ref) async {
  if (kIsWeb) return null;
  try {
    final access = await PhotoManager.requestPermissionExtend();
    if (!access.hasAccess) return null;
    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (albums.isEmpty) return null;
    final newest = await albums.first.getAssetListRange(start: 0, end: 1);
    if (newest.isEmpty) return null;
    return await newest.first.thumbnailDataWithSize(
      const ThumbnailSize(240, 300),
    );
  } catch (_) {
    return null;
  }
});
