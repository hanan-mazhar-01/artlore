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

  static const _radius = 28.0;

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
    final frameColor = (scanning || detected)
        ? p.accent
        // White reads on the dark scanner; on the light theme it would vanish
        // into the backdrop, so the brown accent takes its place.
        : (context.isDark
              ? const Color(0xFFFFFFFF).withValues(alpha: .9)
              : p.accentAlpha(.9));
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
                Text(headerText, style: AppTypography.serif(26, italic: true)),
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
                  borderRadius: BorderRadius.circular(_radius),
                  child: _WallPainting(
                    painting: painting,
                    cameraController: cameraController,
                    snapped: scanning,
                    zoom: zoom,
                  ),
                ),
              ),
              // A fine white rounded edge all the way round the live view.
              Positioned.fill(
                child: IgnorePointer(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: frameColor),
                    duration: AppMotion.medium,
                    builder: (context, c, _) => DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_radius),
                        border: Border.all(color: c!, width: 1.8),
                      ),
                    ),
                  ),
                ),
              ),
              // Scan corners, set in from the frame edge so the live view
              // shows around them.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: (scanning || detected)
                          ? p.accent
                          : const Color(0xFFFFFFFF),
                    ),
                    duration: AppMotion.medium,
                    builder: (context, c, _) => CornerBrackets(
                      color: c!,
                      radius: 14,
                      stroke: 2.6,
                      size: 30,
                    ),
                  ),
                ),
              ),
              if (scanning)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_radius),
                    child: const SweepLine(
                      period: Duration(milliseconds: 1000),
                    ),
                  ),
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
                          borderRadius: BorderRadius.circular(_radius),
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

    // The live view is shown straight — no tilt, skew or scale. The real
    // camera already zooms via setZoomLevel(), so only simulate zoom here when
    // there's no live camera (the static fallback painting).
    final visualZoom = cameraController == null ? zoom : 1.0;
    if (visualZoom == 1.0) return image;
    return Transform.scale(scale: visualZoom, child: image);
  }
}
