import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_filters.dart';
import '../../../../core/widgets/ambient_motion.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/design_stage.dart';

/// The simulated camera view: a painting on a gallery wall that squares up,
/// brightens and is locked by the frame once detected.
///
/// Authored on the design's stage (y 160 → 545 of the 844pt frame).
class ScanViewfinder extends StatelessWidget {
  const ScanViewfinder({
    super.key,
    required this.painting,
    required this.detected,
  });

  final ArtImageSource painting;
  final bool detected;

  static const _ready = Rect.fromLTWH(30, 68, 330, 310);
  static const _locked = Rect.fromLTWH(36, 93, 318, 258);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final frameColor = detected ? p.accent : p.line(.7);
    return DesignStage(
      height: 385,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 8,
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Column(
              key: ValueKey(detected),
              children: [
                Text(
                  detected ? 'Artwork detected' : 'Align the artwork',
                  style: AppTypography.serif(26, italic: true),
                ),
                const SizedBox(height: 6),
                Text(
                  detected
                      ? 'Hold still — tap to read it'
                      : 'Keep the whole canvas inside the frame',
                  style: AppTypography.caption.copyWith(color: p.muted),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 45,
          top: 102,
          width: 300,
          height: 240,
          child: _WallPainting(painting: painting, detected: detected),
        ),
        AnimatedPositioned.fromRect(
          rect: detected ? _locked : _ready,
          duration: const Duration(milliseconds: 900),
          curve: AppMotion.reveal,
          child: Stack(
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: frameColor),
                  duration: AppMotion.medium,
                  builder: (context, c, _) => CornerBrackets(color: c!),
                ),
              ),
              if (detected)
                const Positioned.fill(
                  child: SweepLine(period: Duration(milliseconds: 1800)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WallPainting extends StatelessWidget {
  const _WallPainting({required this.painting, required this.detected});

  final ArtImageSource painting;
  final bool detected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final image = DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          const BoxShadow(color: AppColors.frameWood, spreadRadius: 6),
          BoxShadow(
            color: p.shadow.withValues(alpha: .7),
            offset: const Offset(0, 20),
            blurRadius: 50,
          ),
        ],
      ),
      child: RepaintBoundary(child: ArtImage(painting)),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(end: detected ? 1 : 0),
      duration: AppMotion.slow,
      curve: AppMotion.reveal,
      child: image,
      builder: (context, t, child) {
        final tilt = 1 - t;
        final blur = .6 * tilt;
        Widget out = ColorFiltered(
          colorFilter: ColorFilters.grade(brightness: .7 + .25 * t),
          child: child,
        );
        if (blur > .05) {
          out = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: out,
          );
        }
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 1 / 900)
            ..rotateY(-9 * math.pi / 180 * tilt)
            ..rotateZ(-2 * math.pi / 180 * tilt)
            ..scaleByDouble(.94 + .06 * t, .94 + .06 * t, 1, 1),
          child: out,
        );
      },
    );
  }
}
