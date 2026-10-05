import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_motion.dart';
import '../../../../core/widgets/design_stage.dart';
import 'scan_camera_feed.dart';

/// The simulated camera view: a live camera stream inside rounded scanner bounds,
/// squared up and locked with corner brackets.
class ScanViewfinder extends StatelessWidget {
  const ScanViewfinder({
    super.key,
    this.painting,
    required this.detected,
    this.scanning = false,
    this.zoom = 1.0,
    this.cameraController,
  });

  final ArtImageSource? painting;
  final bool detected;
  final bool scanning;
  final double zoom;
  final CameraController? cameraController;

  static const _ready = Rect.fromLTWH(32, 68, 326, 306);
  static const _locked = Rect.fromLTWH(38, 74, 314, 294);

  /// Width/height of the visible scanner frame — what the camera preview is
  /// windowed to on screen via `BoxFit.cover`. Captured photos are cropped
  /// to this same ratio so the saved image matches what the user framed,
  /// instead of the camera's full (wider) sensor output.
  static const aspectRatio = 326 / 306;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final frameColor = (scanning || detected) ? p.accent : p.line(.7);
    final headerText = scanning
        ? 'Scanning artwork…'
        : detected
        ? 'Artwork detected'
        : 'Align the artwork';
    final subtitleText = scanning
        ? 'Analyzing composition & brushwork…'
        : detected
        ? 'Hold still — tap shutter to scan'
        : 'Keep the whole canvas inside the frame';

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
              key: ValueKey('$detected-$scanning'),
              children: [
                Text(
                  headerText,
                  style: AppTypography.serif(26, italic: true),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitleText,
                  style: AppTypography.caption.copyWith(color: p.muted),
                ),
              ],
            ),
          ),
        ),
        // Live camera screen extending directly to the rounded golden brackets
        AnimatedPositioned.fromRect(
          rect: scanning ? _locked : _ready,
          duration: const Duration(milliseconds: 450),
          curve: AppMotion.reveal,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _WallPainting(
                    painting: painting,
                    cameraController: cameraController,
                    snapped: scanning,
                    zoom: zoom,
                  ),
                ),
              ),
              Positioned.fill(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: frameColor),
                  duration: AppMotion.medium,
                  builder: (context, c, _) => CornerBrackets(
                    color: c!,
                    radius: 12,
                    stroke: 2.2,
                    size: 32,
                  ),
                ),
              ),
              if (scanning)
                const Positioned.fill(
                  child: SweepLine(period: Duration(milliseconds: 1000)),
                ),
              if (scanning)
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.55, end: 0.0),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    builder: (context, opacity, _) => IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.cameraWarm.withValues(
                            alpha: opacity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WallPainting extends StatelessWidget {
  const _WallPainting({
    this.painting,
    required this.snapped,
    required this.zoom,
    this.cameraController,
  });

  final ArtImageSource? painting;
  final bool snapped;
  final double zoom;
  final CameraController? cameraController;

  @override
  Widget build(BuildContext context) {
    final image = RepaintBoundary(
      child: Hero(
        tag: 'scan-viewfinder-hero',
        createRectTween: (begin, end) => AppMotion.rectTween(begin, end),
        child: ScanCameraFeed(
          controller: cameraController,
          fallbackPainting: painting,
          fit: BoxFit.cover,
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(end: snapped ? 1 : 0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      child: image,
      builder: (context, t, child) {
        final tilt = 1 - t;
        // The real camera already zooms via setZoomLevel(), and its preview
        // texture reflects that — so only simulate zoom visually here when
        // there's no live camera (the static fallback painting). Otherwise
        // this would double-apply zoom: once for real, once cosmetically,
        // making the frame look more zoomed in than what actually gets
        // captured.
        final visualZoom = cameraController == null ? zoom : 1.0;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 1 / 900)
            ..rotateY(-7 * math.pi / 180 * tilt)
            ..rotateZ(-1.5 * math.pi / 180 * tilt)
            ..scaleByDouble(
              (1.0 + .04 * t) * visualZoom,
              (1.0 + .04 * t) * visualZoom,
              1,
              1,
            ),
          child: child,
        );
      },
    );
  }
}
