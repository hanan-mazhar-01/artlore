import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_motion.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'editorial_text.dart';

/// Presents [child] in the design's warm bottom sheet, rising with the
/// house sheet curve over a soft scrim.
Future<T?> showArtSheet<T>(BuildContext context, {required Widget child}) {
  final p = context.palette;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: p.scrim,
    elevation: 0,
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.of(context, const Duration(milliseconds: 550)),
      reverseDuration: const Duration(milliseconds: 300),
      curve: AppMotion.sheet,
    ),
    builder: (_) => ArtSheetSurface(child: child),
  );
}

/// The sheet surface: rounded top, grab handle, safe-area padding.
class ArtSheetSurface extends StatelessWidget {
  const ArtSheetSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 14, 24, 40),
    this.radius = 30,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = context.bottomInset;
    return Container(
      width: double.infinity,
      padding: padding.copyWith(
        bottom: padding.bottom + (bottom > 0 ? bottom - 20 : 0),
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: AppShadows.sheet(p),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: p.line(.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A short editorial note in a sheet — used for Privacy and About.
class InfoSheet extends StatelessWidget {
  const InfoSheet({
    super.key,
    required this.kicker,
    required this.title,
    required this.body,
  });

  final String kicker;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GoldLabel(kicker, tracking: .24),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.serif(28, weight: FontWeight.w500)),
        const SizedBox(height: 14),
        Text(body, style: AppTypography.body.copyWith(color: p.muted)),
        const SizedBox(height: 8),
      ],
    );
  }
}
