import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
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
      // A long, decelerating rise: the sheet arrives fast, then settles while
      // its contents come in one after another.
      animation: AppMotion.reduced(context)
          ? null
          : const AnimationStyle(
              duration: Duration(milliseconds: 900),
              reverseDuration: Duration(milliseconds: 320),
              curve: Cubic(.16, 1, .3, 1),
            ),
    );
    if (photoId == null || !context.mounted) return;
    await _gateAndReadPhoto(context, ref, photoId);
  }

  static Future<void> _gateAndReadPhoto(
    BuildContext context,
    WidgetRef ref,
    String photoId,
  ) async {
    final status = await ref.read(premiumProvider.future);
    if (!context.mounted) return;
    if (!status.canScan) {
      if (status.requiresAccount) {
        final unlocked = await context.push<bool>(AppRoutes.accountWall);
        if (unlocked == true && context.mounted) {
          await _gateAndReadPhoto(context, ref, photoId);
        }
        return;
      }
      context.push(AppRoutes.paywall);
      return;
    }
    context.push(AppRoutes.readingPhoto(photoId));
  }
}
