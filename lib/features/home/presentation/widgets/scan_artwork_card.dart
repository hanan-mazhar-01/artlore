import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import 'home_style.dart';

/// The hero. A short film plays on loop: a painting fills the width under a
/// light that scans down it, then slides to the left while the painting's
/// story — title, artist, year, museum — writes itself in on the right, then
/// it all folds back. Under it the headline, copy and "Scan a Painting" pill
/// stay put. The whole card opens the scanner.
class ScanArtworkCard extends StatefulWidget {
  const ScanArtworkCard({
    super.key,
    required this.artwork,
    required this.onTap,
  });

  /// The sample painting the banner scans and describes.
  final Artwork artwork;

  final VoidCallback onTap;

  @override
  State<ScanArtworkCard> createState() => _ScanArtworkCardState();
}

class _ScanArtworkCardState extends State<ScanArtworkCard>
    with TickerProviderStateMixin {
  /// The motes: one 4.5 s cycle, each offset by its own delay.
  late final AnimationController _motes = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4500),
  );

  // (left %, top px, delay s)
  static const _moteSpec = [
    (70.0, 150.0, 0.0),
    (82.0, 120.0, 1.4),
    (62.0, 200.0, 2.6),
    (90.0, 180.0, 3.5),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _motes.stop();
    } else if (!_motes.isAnimating) {
      _motes.repeat();
    }
  }

  @override
  void dispose() {
    _motes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    return Tappable(
      onTap: widget.onTap,
      semanticLabel: 'Scan an artwork',
      haptic: HapticKind.light,
      pressedScale: .985,
      child: Container(
        decoration: BoxDecoration(
          color: s.bannerBg,
          gradient: s.bannerGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: s.bannerBorder),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.55),
              offset: const Offset(0, 24),
              blurRadius: 40,
              spreadRadius: -22,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: Stack(
            children: [
              // A soft glow behind the frame.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -.35),
                      radius: .95,
                      colors: [s.bannerGlow, s.bannerGlow.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              // Motes drifting up behind the content.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _motes,
                    builder: (context, _) => LayoutBuilder(
                      builder: (context, c) => Stack(
                        children: [
                          for (final (x, y, delay) in _moteSpec)
                            _mote(c.maxWidth * x / 100, y, delay, s.bannerMote),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISCOVER THE STORY',
                      style: AppTypography.sans(
                        10.5,
                        weight: FontWeight.w700,
                        tracking: .23,
                      ).copyWith(color: s.bannerAccent),
                    ),
                    const SizedBox(height: 12),
                    _ScanStage(artwork: widget.artwork, style: s),
                    const SizedBox(height: 14),
                    _Copy(style: s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mote(double left, double top, double delay, Color color) {
    final seconds = _motes.value * 4.5;
    final phase = (((seconds - delay) % 4.5) + 4.5) % 4.5 / 4.5;
    // 0 → .9 by 30%, then back to 0; drifts 60px up.
    final opacity = phase < .3
        ? .9 * (phase / .3)
        : .9 * (1 - (phase - .3) / .7);
    final lift = 60 * Curves.easeOut.transform(phase);
    return Positioned(
      left: left,
      top: top - lift,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color, blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}

/// The film strip of the banner: scan, slide left, story, fold back.
class _ScanStage extends StatefulWidget {
  const _ScanStage({required this.artwork, required this.style});

  final Artwork artwork;
  final HomeStyle style;

  @override
  State<_ScanStage> createState() => _ScanStageState();
}

class _ScanStageState extends State<_ScanStage> with TickerProviderStateMixin {
  static const _height = 124.0;

  /// Width the painting shrinks to once it has slid left.
  static const _smallWidth = 132.0;

  /// The scanning light: one pass every 2.6 s, throughout.
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  /// The whole film, ~10 s, looping.
  late final AnimationController _film = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _scan.stop();
      _film
        ..stop()
        ..value = .5; // rest on the "story" frame
    } else {
      if (!_scan.isAnimating) _scan.repeat();
      if (!_film.isAnimating) _film.repeat();
    }
  }

  @override
  void dispose() {
    _scan.dispose();
    _film.dispose();
    super.dispose();
  }

  /// 0 → 1 across [from]..[to] of the film, clamped.
  double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final a = widget.artwork;
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, c) {
          final full = c.maxWidth;
          return AnimatedBuilder(
            animation: Listenable.merge([_film, _scan]),
            builder: (context, _) {
              final t = _film.value;
              // Slide left, hold, fold back.
              final move = Curves.easeInOutCubic.transform(
                _span(t, .16, .28) - _span(t, .86, .96),
              );
              final width = full + (_smallWidth - full) * move;
              // The story leaves quickly, just before the fold-back.
              final storyOut = 1 - _span(t, .80, .85);

              Widget line(int i, Widget child) {
                final p = Curves.easeOutCubic.transform(
                  _span(t, .24 + i * .035, .33 + i * .035),
                );
                final v = (p * storyOut).clamp(0.0, 1.0);
                return Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(18 * (1 - p), 0),
                    child: child,
                  ),
                );
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The story, to the right of the painting.
                  Positioned(
                    left: _smallWidth + 16,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        line(
                          0,
                          Text(
                            a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.serif(
                              20,
                              weight: FontWeight.w700,
                              height: 1.1,
                            ).copyWith(color: s.bannerText),
                          ),
                        ),
                        const SizedBox(height: 5),
                        line(
                          1,
                          Text(
                            a.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              12.5,
                              weight: FontWeight.w600,
                            ).copyWith(color: s.bannerAccentSoft),
                          ),
                        ),
                        const SizedBox(height: 4),
                        line(
                          2,
                          Text(
                            '${a.year} · ${a.movement}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              11.5,
                              weight: FontWeight.w500,
                            ).copyWith(color: s.bannerBody(.78)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        line(
                          3,
                          Text(
                            '${a.museum}, ${a.city}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              11.5,
                              weight: FontWeight.w500,
                              height: 1.25,
                            ).copyWith(color: s.bannerBody(.6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The painting and its scan frame.
                  Positioned(
                    left: 0,
                    top: 0,
                    width: width,
                    height: _height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Opacity(
                              opacity: s.bannerImageOpacity,
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
                                // Decoded once at full size and scaled by the strip, so the
                                // picture never reloads while it slides.
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    alignment: a.heroFocus,
                                    child: SizedBox(
                                      width: full - 6,
                                      height: _height - 6,
                                      child: ArtImage(
                                        a.image,
                                        alignment: a.heroFocus,
                                        semanticLabel:
                                            'Starry Night, sample scan',
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
                            color: s.bannerAccent,
                            size: 18,
                            stroke: 2,
                            radius: 6,
                          ),
                        ),
                        _ScanLine(t: _scan.value, frameHeight: _height),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The light bar that scans down the frame, top to bottom.
class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.t, required this.frameHeight});

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

class _Copy extends StatelessWidget {
  const _Copy({required this.style});

  final HomeStyle style;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 215),
          child: Text.rich(
            TextSpan(
              style: AppTypography.serif(
                32,
                weight: FontWeight.w700,
                height: 1.04,
              ).copyWith(color: s.bannerText),
              children: [
                const TextSpan(text: 'Every Painting Has a '),
                TextSpan(
                  text: 'Story',
                  style: TextStyle(color: s.bannerAccentSoft),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            'Scan a masterpiece and uncover the story behind every brushstroke.',
            style: AppTypography.sans(
              13,
              weight: FontWeight.w500,
              height: 1.45,
            ).copyWith(color: s.bannerBody(.82)),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 18, right: 8),
          decoration: BoxDecoration(
            color: s.bannerBtnBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: s.bannerBtnBg.withValues(alpha: .4),
                offset: const Offset(0, 10),
                blurRadius: 22,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ArtIcon(
                ArtIcons.camera,
                size: 18,
                color: s.bannerBtnInk,
                strokeWidth: 1.9,
              ),
              const SizedBox(width: 10),
              Text(
                'Scan a Painting',
                style: AppTypography.sans(
                  14.5,
                  weight: FontWeight.w700,
                ).copyWith(color: s.bannerBtnInk),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: s.bannerBtnDisc,
                  shape: BoxShape.circle,
                ),
                child: ArtIcon(
                  ArtIcons.arrowRight,
                  size: 16,
                  color: s.bannerBtnArrow,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
