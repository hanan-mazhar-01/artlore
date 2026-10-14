import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/router/tab_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';

/// The front door of the app: a banner over a painting — "AI powered" chip,
/// headline, one line of copy and a gold pill button. The whole card opens the
/// scanner.
class ScanArtworkCard extends StatefulWidget {
  const ScanArtworkCard({
    super.key,
    required this.artwork,
    required this.onTap,
  });

  /// The painting shown inside the frame.
  final ArtImageSource artwork;
  final VoidCallback onTap;

  @override
  State<ScanArtworkCard> createState() => _ScanArtworkCardState();
}

class _ScanArtworkCardState extends State<ScanArtworkCard> {
  static const _outerRadius = 24.0;
  static const _innerRadius = 18.0;
  static const _imageHeight = 222.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(_innerRadius - 3),
      child: SizedBox(
        height: _imageHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // A hair of blur so the button and copy read as sitting above
            // the painting rather than printed on it.
            Hero(
              tag: 'scan-viewfinder-hero',
              createRectTween: (begin, end) => AppMotion.rectTween(begin, end),
              flightShuttleBuilder: (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) {
                return AppMotion.heroShuttle(
                  animation: animation,
                  flightDirection: flightDirection,
                  fromHeroContext: fromHeroContext,
                  toHeroContext: toHeroContext,
                  startRadius: BorderRadius.circular(_innerRadius - 3),
                  endRadius: BorderRadius.zero,
                );
              },
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 1.4),
                child: ArtImage(
                  widget.artwork,
                  semanticLabel: 'Starry Night, sample scan',
                ),
              ),
            ),
            // Darkens the left side, where the copy sits, and lets the
            // painting show through on the right.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xE6101010),
                    Color(0xB3101010),
                    Color(0x26101010),
                  ],
                  stops: [0, .55, 1],
                ),
              ),
            ),
            // Scales the copy down rather than ever overflowing the card.
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _BannerCopy(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Tappable(
      onTap: widget.onTap,
      semanticLabel: 'Scan an artwork',
      haptic: HapticKind.light,
      pressedScale: .985,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(_outerRadius),
          boxShadow: AppShadows.card(p),
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: p.accentAlpha(.5)),
            borderRadius: BorderRadius.circular(_innerRadius),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Left-aligned copy block of the banner. The first time it appears it writes
/// itself in: the headline types out behind a blinking cursor, then the line
/// of copy rises in and the button settles into place. After that only the
/// headline keeps typing, over and over; the rest stays put.
class _BannerCopy extends StatefulWidget {
  const _BannerCopy();

  @override
  State<_BannerCopy> createState() => _BannerCopyState();
}

class _BannerCopyState extends State<_BannerCopy>
    with TickerProviderStateMixin {
  static const _gold = AppColors.gold;
  static const _headline = 'Turn Any\nPainting Into\na Story';
  static const _goldFrom = _headline.length - 'a Story'.length;
  static const _intro = Duration(milliseconds: 3800);
  static const _typeOnly = Duration(milliseconds: 2900);

  /// Where in the repeat the headline is done and the button gives its nudge.
  static const _typedBy = .74;

  /// Gap between one typing pass finishing and the next starting.
  static const _hold = Duration(milliseconds: 2500);

  /// The full first-time timeline.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _intro,
  );

  /// Just the headline, for the repeats.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: _typeOnly,
  );

  late final Animation<double> _typing = CurvedAnimation(
    parent: _c,
    curve: const Interval(.06, .56),
  );
  late final Animation<double> _copy = CurvedAnimation(
    parent: _c,
    curve: const Interval(.58, .78, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _button = CurvedAnimation(
    parent: _c,
    curve: const Interval(.72, .96, curve: Curves.easeOutBack),
  );
  late final Animation<double> _loopTyping = CurvedAnimation(
    parent: _loop,
    curve: const Interval(.04, _typedBy),
  );

  Timer? _timer;
  bool _active = false;

  /// True once the first full write-in has finished.
  bool _introDone = false;

  void _play() {
    _timer?.cancel();
    if (AppMotion.reduced(context)) {
      _c.value = 1;
      _loop.value = 1;
      _introDone = true;
      return;
    }
    _timer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || !_active) return;
      if (_introDone) {
        _playLoop();
      } else {
        _c.forward(from: 0).whenCompleteOrCancel(() {
          if (!mounted || !_active || _c.value < 1) return;
          _introDone = true;
          _loop.value = 1;
          _schedule();
        });
      }
    });
  }

  void _playLoop() {
    _loop.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted || !_active || _loop.value < 1) return;
      _schedule();
    });
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(_hold, () {
      if (mounted && _active) _playLoop();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only the Home tab runs it; leaving and coming back starts it afresh.
    final onHome = ActiveTabScope.of(context) == 0;
    if (onHome && !_active) {
      _active = true;
      if (!_introDone) _c.value = 0;
      _play();
    } else if (!onHome && _active) {
      _active = false;
      _timer?.cancel();
      _c.stop();
      _loop.stop();
      if (_introDone) {
        _loop.value = 1;
      } else {
        _c.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// A very slight swell of the button once the headline has finished typing:
  /// up about 3.5% and back, in one smooth breath.
  double get _nudge {
    final t = _loop.value;
    if (t <= _typedBy) return 1;
    final p = (t - _typedBy) / (1 - _typedBy);
    return 1 + .035 * math.sin(math.pi * p);
  }

  /// Typing progress, 0–1, from whichever timeline is current.
  double get _typed => _introDone ? _loopTyping.value : _typing.value;

  /// The cursor: shown while typing and for a moment after, blinking twice a
  /// second, then gone.
  bool get _cursorOn {
    final AnimationController ctl = _introDone ? _loop : _c;
    final t = ctl.value;
    if (t >= (_introDone ? _typedBy + .05 : .8) || t <= 0) return false;
    final ms = t * ctl.duration!.inMilliseconds;
    return (ms ~/ 480).isEven;
  }

  InlineSpan _headlineSpan(int typed) {
    final spans = <InlineSpan>[];
    void run(int from, int to, Color color) {
      if (to <= from) return;
      spans.add(
        TextSpan(
          text: _headline.substring(from, to),
          style: TextStyle(color: color),
        ),
      );
    }

    // Typed part, in its final colours.
    run(0, typed.clamp(0, _goldFrom), AppColors.ivory);
    if (typed > _goldFrom) run(_goldFrom, typed, _gold);

    // Zero-width cursor, so it never nudges the text around it.
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SizedBox(
          width: 0,
          height: 26,
          child: OverflowBox(
            maxWidth: 4,
            alignment: Alignment.centerLeft,
            child: Container(
              width: 2.5,
              height: 24,
              margin: const EdgeInsets.only(left: 2),
              color: _cursorOn ? _gold : const Color(0x00000000),
            ),
          ),
        ),
      ),
    );

    // The rest is laid out but invisible, so the lines never reflow.
    const clear = Color(0x00000000);
    run(typed, _headline.length, clear);
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: AnimatedBuilder(
        animation: Listenable.merge([_c, _loop]),
        builder: (context, _) {
          final typed = (_typed * _headline.length).round();
          final copy = _introDone ? 1.0 : _copy.value;
          final button = _introDone ? 1.0 : _button.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: AppTypography.sans(
                    23,
                    weight: FontWeight.w800,
                    height: 1.12,
                  ),
                  children: [_headlineSpan(typed)],
                ),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: copy.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 8 * (1 - copy)),
                  child: Text(
                    'Point, scan and discover the hidden story behind the '
                    'artwork.',
                    style: AppTypography.sans(
                      11.5,
                      height: 1.4,
                    ).copyWith(color: AppColors.ivory.withValues(alpha: .82)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: button.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - button)),
                  child: Transform.scale(
                    scale: _introDone ? _nudge : .94 + .06 * button,
                    alignment: Alignment.centerLeft,
                    child: const _PillButton(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton();

  static const _ink = AppColors.night;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ArtIcon(ArtIcons.camera, size: 16, color: _ink),
          const SizedBox(width: 8),
          Text(
            'Scan a Painting',
            style: AppTypography.sans(
              13.5,
              weight: FontWeight.w700,
            ).copyWith(color: _ink),
          ),
          const SizedBox(width: 10),
          const ArtIcon(
            ArtIcons.arrowRight,
            size: 15,
            color: _ink,
            strokeWidth: 1.9,
          ),
        ],
      ),
    );
  }
}
