import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import 'home_style.dart';
import 'scan_frame.dart';
import 'splash_handoff.dart';

/// The hero. A short film plays on loop: a painting fills the width under a
/// light that scans down it, then slides to the left while the painting's
/// story — title, artist, year, museum — writes itself in on the right, then
/// it all folds back. Under it the headline, copy and "Scan a Painting" pill
/// stay put. Tapping the card opens the painting's own page — its story, Look
/// Closer and the deep dive — to show how the app works; the "Scan a Painting"
/// pill opens the scanner.
class ScanArtworkCard extends StatefulWidget {
  const ScanArtworkCard({
    super.key,
    required this.artwork,
    required this.onTap,
    required this.onScan,
  });

  /// The sample painting the banner scans and describes.
  final Artwork artwork;

  /// The card was tapped: open the painting.
  final VoidCallback onTap;

  /// The "Scan a Painting" pill was tapped: open the scanner.
  final VoidCallback onScan;

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

  /// Rounded on three corners; the top-right is nearly square, because the
  /// gilded frame corner sits on it.
  static BorderRadius _corners(double r) => BorderRadius.only(
    topLeft: Radius.circular(r),
    bottomLeft: Radius.circular(r),
    bottomRight: Radius.circular(r),
    topRight: const Radius.circular(6),
  );

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    return Tappable(
      onTap: widget.onTap,
      semanticLabel:
          'Open ${widget.artwork.title} — see how ArtLore tells its story',
      haptic: HapticKind.light,
      pressedScale: .985,
      child: _GildedCorner(
        child: Container(
          decoration: BoxDecoration(
            color: s.bannerBg,
            gradient: s.bannerGradient,
            borderRadius: _corners(30),
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
            borderRadius: _corners(29),
            child: Stack(
              children: [
                // A soft glow behind the frame.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -.35),
                        radius: .95,
                        colors: [
                          s.bannerGlow,
                          s.bannerGlow.withValues(alpha: 0),
                        ],
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
                              _mote(
                                c.maxWidth * x / 100,
                                y,
                                delay,
                                s.bannerMote,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
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
                      _Copy(style: s, onScan: widget.onScan),
                    ],
                  ),
                ),
              ],
            ),
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
  static const _height = 108.0;

  /// Width the painting shrinks to once it has slid left.
  /// The painting's width once the story opens beside it, as a share of the
  /// banner's inner width (kept within a range).
  static double _smallWidthFor(double full) => (full * .41).clamp(84.0, 124.0);

  /// True while this banner is receiving the splash's frame: the frame flies
  /// in and lands square, then opens out before the film begins.
  late bool _handoff = SplashHandoff.active;

  /// The frame opening out from the square to the full strip.
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  final _stageKey = GlobalKey();

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
  void initState() {
    super.initState();
    if (_handoff) {
      // Tell the flying frame where to land, and wait for it.
      SplashHandoff.targetProvider = _frameRect;
      SplashHandoff.landed.addListener(_onLanded);
    }
  }

  /// Where the square frame sits on screen right now, for the flight to aim at.
  Rect? _frameRect() {
    final box = _stageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      origin.dx,
      origin.dy,
      _smallWidthFor(box.size.width),
      _height,
    );
  }

  void _onLanded() {
    if (!SplashHandoff.landed.value) return;
    SplashHandoff.landed.removeListener(_onLanded);
    SplashHandoff.targetProvider = null;
    if (!mounted) return;
    // The frame has landed: open it out straight away, then let the film run.
    setState(() {});
    _open.forward().then((_) {
      if (!mounted) return;
      setState(() => _handoff = false);
      if (!AppMotion.reduced(context)) _film.repeat();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handoff && !AppMotion.reduced(context)) {
      // The film waits for the frame to open out.
      if (!_scan.isAnimating) _scan.repeat();
      return;
    }
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
    SplashHandoff.landed.removeListener(_onLanded);
    if (SplashHandoff.targetProvider == _frameRect) {
      SplashHandoff.targetProvider = null;
    }
    _open.dispose();
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
      key: _stageKey,
      height: _height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, c) {
          final full = c.maxWidth;
          final small = _smallWidthFor(full);
          return AnimatedBuilder(
            animation: Listenable.merge([_film, _scan, _open]),
            builder: (context, _) {
              final t = _film.value;
              // Slide left, hold, fold back.
              final move = Curves.easeInOutCubic.transform(
                _span(t, .16, .28) - _span(t, .86, .96),
              );
              final opened = Curves.easeInOutCubic.transform(_open.value);
              final width = _handoff
                  ? small + (full - small) * opened
                  : full + (small - full) * move;
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
                    left: small + 14,
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
                              17.5,
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
                              10.5,
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
                              10.5,
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
                    child: Opacity(
                      // While the splash's frame is still flying in, it is the
                      // one on show; this one waits underneath.
                      opacity: _handoff && !SplashHandoff.landed.value ? 0 : 1,
                      child: ScanFrame(
                        artwork: a,
                        style: s,
                        scan: _scan,
                        cropBox: Size(full - 6, _height - 6),
                        backdrop: _handoff ? 1 - opened : 0,
                        heroEnabled: !_handoff,
                      ),
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

class _Copy extends StatelessWidget {
  const _Copy({required this.style, required this.onScan});

  final HomeStyle style;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tappable(
          onTap: onScan,
          semanticLabel: 'Scan a painting',
          haptic: HapticKind.light,
          pressedScale: .96,
          child: Container(
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
        ),
      ],
    );
  }
}

/// The gilded frame corner, laid over the banner's top-right corner so the
/// banner's rounded corner is hidden beneath it. Drawn outside the banner's
/// clip, sized by the banner's width and placed from the ornament's own
/// proportions (its arms run just inside the banner's edges), so it fits the
/// corner the same on every phone.
class _GildedCorner extends StatelessWidget {
  const _GildedCorner({required this.child});

  final Widget child;

  /// The asset's size, and where its arms' centre lines sit within it.
  static const _imageWidth = 430.0;
  static const _armFromTop = 48.5;
  static const _armFromRight = 68.0;

  /// Ornament width as a share of the banner's width, kept within a range so
  /// it neither crowds the label on a narrow phone nor balloons on a wide one.
  static const _share = .34;
  static const _minWidth = 90.0;
  static const _maxWidth = 112.0;

  /// How far inside the banner's edges the arms run (logical px).
  static const _inset = 1.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth * _share).clamp(_minWidth, _maxWidth);
        final k = w / _imageWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: _inset - _armFromTop * k,
              right: _inset - _armFromRight * k,
              width: w,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/frame/corner.png',
                  fit: BoxFit.contain,
                  cacheWidth: (w * 3).round(),
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
