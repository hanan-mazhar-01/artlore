import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/art_sheet.dart';
import '../../paywall/presentation/premium_controller.dart';
import 'widgets/photo_picker_sheet.dart';

/// Entry points into recognition, shared by every screen that offers them.
abstract final class ScanLauncher {
  /// Opens the live camera scanner.
  static void camera(BuildContext context) => context.push(AppRoutes.scan);

  /// Picks a library photo and reads it — or offers Premium when the free
  /// scans are used up.
  static Future<void> fromPhotos(BuildContext context, WidgetRef ref) async {
    final photoId = await showArtSheet<String>(
      context,
      child: const PhotoPickerSheet(),
    );
    if (photoId == null || !context.mounted) return;
    final status = await ref.read(premiumProvider.future);
    if (!context.mounted) return;
    if (!status.canScan) {
      context.push(AppRoutes.paywall);
      return;
    }
    context.push(AppRoutes.readingPhoto(photoId));
  }
}
