import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_motion.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/reveal_image.dart';
import '../../../artwork/data/mock_catalog.dart';
import 'onboarding_collages_more.dart';

/// The four arrival compositions, authored on a 390 × 540 stage.
const onboardingStageHeight = 540.0;

Widget onboardingCollage(int index) => switch (index) {
  0 => const _MysteryCollage(),
  1 => const _ScanCollage(),
  2 => const CloserCollage(),
  _ => const GalleryCollage(),
};

/// Vermeer in an arch, with a quiet question.
class _MysteryCollage extends StatelessWidget {
  const _MysteryCollage();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pearl = mockCatalog[ArtworkIds.pearlEarring]!;
    return DesignStage(
      height: onboardingStageHeight,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          left: 44,
          top: 96,
          width: 262,
          height: 410,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.css(131, 131, 6, 6),
              border: Border.all(color: p.line(.16), width: 0.8),
              boxShadow: AppShadows.artwork(p),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.css(131, 131, 6, 6),
              child: RevealImage(
                pearl.image,
                alignment: const Alignment(0, -.4),
                semanticLabel: pearl.semanticLabel,
              ),
            ),
          ),
        ),
        Positioned(
          right: 28,
          top: 150,
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              'VERMEER · C. 1665',
              style: AppTypography.sans(
                10,
                tracking: .3,
              ).copyWith(color: p.muted),
            ),
          ),
        ),
        Positioned(
          left: 228,
          top: 430,
          width: 110,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 250),
            offset: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: AppRadius.css(4, 22, 4, 22),
                border: Border.all(color: p.line(.12), width: 0.8),
                boxShadow: AppShadows.card(p),
              ),
              child: Text(
                'Who is she? No one knows.',
                style: AppTypography.serif(15, italic: true, height: 1.25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Great Wave caught in a viewfinder.
class _ScanCollage extends StatelessWidget {
  const _ScanCollage();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final wave = mockCatalog[ArtworkIds.greatWave]!;
    return DesignStage(
      height: onboardingStageHeight,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: 150,
          height: 262,
          child: ArtImage(
            wave.image,
            radius: AppRadius.canvas,
            semanticLabel: wave.semanticLabel,
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          top: 136,
          height: 290,
          child: CornerBrackets(
            color: p.accent,
            size: 34,
            stroke: 2.0,
            radius: 6,
          ),
        ),
        const Positioned(
          left: 24,
          right: 24,
          top: 150,
          height: 262,
          child: SweepLine(period: Duration(milliseconds: 2600)),
        ),
        Positioned(
          left: 24,
          top: 440,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            offset: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: p.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: p.accentAlpha(.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'IDENTIFIED · HOKUSAI, C. 1831',
                  style: AppTypography.sans(
                    10,
                    tracking: .24,
                  ).copyWith(color: p.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
