import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show MethodCall;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../artwork/domain/artwork.dart';
import '../../artwork/presentation/artwork_providers.dart';
import '../../collections/presentation/collection_views.dart';
import '../../history/domain/history_entry.dart';
import '../../history/presentation/history_controller.dart';

/// What the app asks the phone for: images only. (The default also asks for
/// video, which the manifest does not declare — on newer Android that makes
/// the request fail without ever showing the popup.)
const photoAccessOption = PermissionRequestOption(
  androidPermission: AndroidPermission(
    type: RequestType.image,
    mediaLocation: false,
  ),
);

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

/// Thumbnails of the two newest photos in the phone's library, newest first,
/// for the "Scan from Photos" card. Empty when access is declined, the library
/// is empty, or there is no photo library (web).
///
/// Re-reads the library whenever it changes (a new photo, a deletion), so the
/// card never holds on to an old picture.
final latestPhotoProvider = FutureProvider.autoDispose<List<Uint8List>>((
  ref,
) async {
  if (kIsWeb) return const [];
  try {
    // Look only — never ask. The permission prompt belongs to the moment the
    // visitor chooses Scan from Photos, not to opening the app.
    final access = await PhotoManager.getPermissionState(
      requestOption: photoAccessOption,
    );
    if (!access.hasAccess) return const [];

    void onChange(MethodCall _) => ref.invalidateSelf();
    PhotoManager.addChangeCallback(onChange);
    PhotoManager.startChangeNotify();
    ref.onDispose(() {
      PhotoManager.removeChangeCallback(onChange);
      PhotoManager.stopChangeNotify();
    });

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      // Strictly newest first, whatever order the platform defaults to.
      filterOption: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate)],
      ),
    );
    if (albums.isEmpty) return const [];
    final newest = await albums.first.getAssetListRange(start: 0, end: 2);
    final thumbs = <Uint8List>[];
    for (final asset in newest) {
      final data = await asset.thumbnailDataWithSize(
        const ThumbnailSize(240, 300),
      );
      if (data != null) thumbs.add(data);
    }
    return thumbs;
  } catch (_) {
    return const [];
  }
});

bool _askedThisRun = false;

/// Asks for photo access when Home or the scanner first appears and the phone
/// has not yet given it. The system shows its own popup only while it can
/// (never given, or declined once); if it has already decided, nothing shows
/// and the photos simply appear (or stay away). Asked once per app run, so
/// opening and closing screens never nags. Returns true if photos can be read.
Future<bool> askPhotoAccessOnce(WidgetRef ref) async {
  if (kIsWeb) return false;
  var granted = false;
  try {
    final state = await PhotoManager.getPermissionState(
      requestOption: photoAccessOption,
    );
    granted = state.hasAccess;
    if (!granted && !_askedThisRun) {
      _askedThisRun = true;
      granted = (await PhotoManager.requestPermissionExtend(
        requestOption: photoAccessOption,
      )).hasAccess;
    }
  } catch (_) {}
  ref.invalidate(latestPhotoProvider);
  return granted;
}
