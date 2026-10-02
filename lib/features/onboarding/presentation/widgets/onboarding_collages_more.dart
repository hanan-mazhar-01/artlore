import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../artwork/data/mock_catalog.dart';
import 'onboarding_collages.dart';

/// A loupe over the cypress of The Starry Night.
class CloserCollage extends StatelessWidget {
  const CloserCollage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final starry = mockCatalog[ArtworkIds.starryNight]!;
    return DesignStage(
      height: onboardingStageHeight,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: Opacity(opacity: .35, child: ArtImage(starry.image)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.ground(.2), p.background],
                stops: const [0, .96],
              ),
            ),
          ),
        ),
        Positioned(
          left: 70,
          top: 130,
          width: 250,
          height: 250,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.accentAlpha(.7)),
              boxShadow: [
                BoxShadow(color: p.ground(.6), spreadRadius: 8),
                BoxShadow(
                  color: p.shadow,
                  offset: const Offset(0, 30),
                  blurRadius: 60,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -40,
                    top: -180,
                    width: 900,
                    height: 720,
                    child: ArtImage(starry.image, decodeScale: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 240,
          top: 390,
          width: 1,
          height: 46,
          child: ColoredBox(color: p.accent),
        ),
        Positioned(
          left: 180,
          top: 446,
          child: Text(
            '01 — The cypress',
            style: AppTypography.serif(17, italic: true),
          ),
        ),
      ],
    );
  }
}

/// Three works hung slightly askew, and a gallery chip.
class GalleryCollage extends StatelessWidget {
  const GalleryCollage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget piece(String id, BorderRadius r, double deg) {
      final a = mockCatalog[id]!;
      return Transform.rotate(
        angle: deg * math.pi / 180,
        child: ArtImage(a.image, radius: r, shadow: AppShadows.collage(p)),
      );
    }

    return DesignStage(
      height: onboardingStageHeight,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          left: 26,
          top: 120,
          width: 170,
          height: 240,
          child: piece(ArtworkIds.kiss, AppRadius.css(85, 85, 4, 4), -4),
        ),
        Positioned(
          left: 176,
          top: 96,
          width: 186,
          height: 150,
          child: piece(ArtworkIds.sunrise, AppRadius.css(4, 48, 4, 48), 3),
        ),
        Positioned(
          left: 150,
          top: 270,
          width: 200,
          height: 230,
          child: piece(ArtworkIds.wanderer, AppRadius.canvas, -1),
        ),
        Positioned(
          left: 40,
          top: 400,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: p.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Night Skies · 5 works', style: AppTypography.sans(11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
