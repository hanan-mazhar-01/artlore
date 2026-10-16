import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../artwork/domain/artwork.dart';
import 'home_style.dart';

/// The scan frame on its own: a painting with corner brackets and the
/// scanning light passing over it. Used by Home's banner, by the splash, and by
/// the frame that flies between them — all three draw it the same way, from the
/// same decoded picture, so it never reloads or jumps.
///
/// [scan] is the light's 0–1 progress; only the light repaints as it moves —
/// the picture and brackets sit in a cached layer. [cropBox] is the shape the picture is
/// cropped to before being fitted to the frame (the banner's strip), so a
/// square frame shows the middle of the strip. [backdrop] fades a dark card
/// behind it (1 on the splash, where it sits on the page; 0 inside the
/// banner, which is already dark).
class ScanFrame extends StatelessWidget {
  const ScanFrame({
    super.key,
    required this.artwork,
    required this.style,
    required this.scan,
    required this.cropBox,
    this.backdrop = 0,
    this.heroEnabled = false,
  });

  final Artwork artwork;
  final HomeStyle style;
  final Animation<double> scan;
  final Size cropBox;
  final double backdrop;

  /// Only the banner's own frame joins the flight to the scan screen.
  final bool heroEnabled;

  /// One decoded size shared by every copy of the picture.
  static const _decodeWidth = 720;

  @override
  Widget build(BuildContext context) {
    final image = ResizeImage.resizeIfNeeded(
      _decodeWidth,
      null,
      artwork.image.provider(),
    );
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdrop > 0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: backdrop.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: style.bannerBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Opacity(
                        opacity: style.bannerImageOpacity,
                        child: HeroMode(
                          enabled: heroEnabled,
                          child: Hero(
                            tag: 'scan-viewfinder-hero',
                            createRectTween: (b, e) =>
                                AppMotion.rectTween(b, e),
                            flightShuttleBuilder:
                                (ctx, animation, direction, from, to) {
                                  return AppMotion.heroShuttle(
                                    animation: animation,
                                    flightDirection: direction,
                                    fromHeroContext: from,
                                    toHeroContext: to,
                                    startRadius: BorderRadius.circular(6),
                                    endRadius: BorderRadius.zero,
                                  );
                                },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                alignment: artwork.heroFocus,
                                child: SizedBox(
                                  width: cropBox.width,
                                  height: cropBox.height,
                                  child: Image(
                                    image: image,
                                    fit: BoxFit.cover,
                                    alignment: artwork.heroFocus,
                                    gaplessPlayback: true,
                                    filterQuality: FilterQuality.medium,
                                    semanticLabel: 'Starry Night, sample scan',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CornerBrackets(
                      color: style.bannerAccent,
                      size: 18,
                      stroke: 2,
                      radius: 6,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: scan,
              builder: (context, _) =>
                  ScanLine(t: scan.value, frameHeight: c.maxHeight),
            ),
          ],
        );
      },
    );
  }
}

/// The light bar that scans down the frame, top to bottom.
class ScanLine extends StatelessWidget {
  const ScanLine({super.key, required this.t, required this.frameHeight});

  final double t;
  final double frameHeight;

  @override
  Widget build(BuildContext context) {
    // 8% → 88% of the frame's height, fading in over the first tenth and out
    // over the last, on an ease-in-out.
    final eased = const Cubic(.45, 0, .55, 1).transform(t);
    final top = frameHeight * (.08 + .80 * eased);
    final opacity = t < .1 ? t / .1 : (t > .9 ? (1 - t) / .1 : 1.0);
    return Positioned(
      left: 4,
      right: 4,
      top: top,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Color(0x00E2C27F), Color(0xFFF0D9A6), Color(0x00E2C27F)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99E2C27F),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
