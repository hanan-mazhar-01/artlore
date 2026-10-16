import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import '../../../artwork/presentation/artwork_providers.dart';
import '../../../history/domain/history_entry.dart';
import '../home_providers.dart';
import 'home_style.dart';

/// "Recent scans": a cover-flow deck. The latest scan sits in front, the
/// earlier ones fan out behind it in depth, and the card that comes forward
/// is scanned once more by a sweep of light. The deck turns
/// only when the visitor swipes or taps, and fans out the first time it scrolls
/// into view. With nothing scanned yet it shows an inviting empty state.
class RecentScansSection extends ConsumerWidget {
  const RecentScansSection({super.key, required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = HomeStyle.of(context);
    final scans = ref.watch(recentScansProvider);

    // The newest scan of each work, with its artwork, up to six.
    final items = <_Scan>[];
    if (scans != null) {
      final seen = <String>{};
      for (final e in scans) {
        if (!seen.add(e.artworkId)) continue;
        final a = ref.watch(artworkProvider(e.artworkId)).value;
        if (a != null) items.add(_Scan(e, a));
        if (items.length == 6) break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (scans == null) ...[
            _Head(style: s),
            const SizedBox(height: _Deck.height + 120),
          ] else if (scans.isEmpty || items.isEmpty) ...[
            _Head(style: s),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _EmptyScans(onScan: onScan, style: s),
            ),
          ] else
            _Deck(items: items, style: s),
        ],
      ),
    );
  }
}

class _Scan {
  const _Scan(this.entry, this.artwork);

  final HistoryEntry entry;
  final Artwork artwork;
}

class _Head extends StatelessWidget {
  const _Head({required this.style, this.seeAll = false});

  final HomeStyle style;

  /// Show the "See all" button, which opens the whole scan history.
  final bool seeAll;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Recent scans',
              style: AppTypography.sans(
                21,
                weight: FontWeight.w700,
                tracking: -.015,
              ).copyWith(color: s.ink),
            ),
          ),
          if (seeAll)
            Tappable(
              onTap: () => context.push(AppRoutes.history),
              semanticLabel: 'See all scans',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: AppTypography.sans(
                        13,
                        weight: FontWeight.w600,
                      ).copyWith(color: s.gold),
                    ),
                    const SizedBox(width: 4),
                    ArtIcon(
                      ArtIcons.chevronRight,
                      size: 14,
                      color: s.gold,
                      strokeWidth: 2.2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Where a card sits as a function of how far it is from the front.
class _Pose {
  const _Pose(
    this.x,
    this.y,
    this.z,
    this.turn,
    this.scale,
    this.dark,
    this.fade,
  );

  final double x, y, z, turn, scale, dark, fade;

  static _Pose lerp(_Pose a, _Pose b, double t) => _Pose(
    a.x + (b.x - a.x) * t,
    a.y + (b.y - a.y) * t,
    a.z + (b.z - a.z) * t,
    a.turn + (b.turn - a.turn) * t,
    a.scale + (b.scale - a.scale) * t,
    a.dark + (b.dark - a.dark) * t,
    a.fade + (b.fade - a.fade) * t,
  );

  // Right-hand cards, by distance from the front: in front, one, two, then
  // tucked away behind. (Flutter's z grows away from the viewer.) The left
  // side mirrors these.
  static const _keys = [
    _Pose(0, 0, 0, 0, 1, 0, 1),
    _Pose(124, 6, 60, -34 * math.pi / 180, .82, .28, 1),
    _Pose(206, 12, 130, -44 * math.pi / 180, .66, .5, .75),
    _Pose(0, 10, 200, 0, .5, 0, 0),
  ];

  /// The pose at signed distance [o] from the front (a fraction mid-move).
  static _Pose at(double o) {
    final a = o.abs().clamp(0.0, 3.0);
    final i = a.floor().clamp(0, 2);
    final p = lerp(_keys[i], _keys[i + 1], a - i);
    final sign = o < 0 ? -1.0 : 1.0;
    return _Pose(sign * p.x, p.y, p.z, sign * p.turn, p.scale, p.dark, p.fade);
  }

  /// Every card starts stacked at the centre and fans out from there.
  static const stacked = _Pose(0, 14, 120, 0, .6, 0, 0);
}

class _Deck extends StatefulWidget {
  const _Deck({required this.items, required this.style});

  final List<_Scan> items;
  final HomeStyle style;

  static const height = 292.0;
  static const cardW = 196.0;
  static const cardH = 262.0;

  @override
  State<_Deck> createState() => _DeckState();
}

class _DeckState extends State<_Deck> with TickerProviderStateMixin {
  static const _ease = Cubic(.2, .8, .2, 1);

  /// The index in front, and the (fractional) position the deck is actually
  /// at while it turns towards it.
  int _index = 0;
  double _pos = 0;
  double _from = 0;
  double _to = 0;

  late final AnimationController _slide =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..addListener(
        () => setState(
          () => _pos = _from + (_to - _from) * _ease.transform(_slide.value),
        ),
      );

  /// Restarts each time a card comes forward: drives its ring and its sweep.
  late final AnimationController _activation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  /// The fan-out the first time the deck is seen.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  bool _entered = false;
  double _drag = 0;
  ScrollPosition? _scroll;

  int get _n => widget.items.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scroll?.removeListener(_checkInView);
    _scroll = Scrollable.maybeOf(context)?.position;
    _scroll?.addListener(_checkInView);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInView());
  }

  @override
  void didUpdateWidget(_Deck old) {
    super.didUpdateWidget(old);
    if (_index >= _n) {
      _index = 0;
      _pos = _from = _to = 0;
    }
  }

  @override
  void dispose() {
    _scroll?.removeListener(_checkInView);
    _slide.dispose();
    _activation.dispose();
    _enter.dispose();
    super.dispose();
  }

  /// Fan out (and start turning) the first time the deck scrolls into view.
  void _checkInView() {
    if (_entered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top > MediaQuery.sizeOf(context).height * .9) return;
    _entered = true;
    _scroll?.removeListener(_checkInView);
    if (AppMotion.reduced(context)) {
      _enter.value = 1;
      _activation.value = 1;
      return;
    }
    _enter.forward();
    _activation.forward(from: 0);
  }

  /// Brings card [i] to the front by the shortest way round.
  void _go(int i) {
    if (_n == 0) return;
    final target = ((i % _n) + _n) % _n;
    var delta = (target - _pos) % _n;
    if (delta > _n / 2) delta -= _n;
    if (delta < -_n / 2) delta += _n;
    setState(() {
      _index = target;
      _from = _pos;
      _to = _pos + delta;
    });
    if (AppMotion.reduced(context)) {
      _pos = _to;
      _activation.value = 1;
    } else {
      _slide.forward(from: 0);
      _activation.forward(from: 0);
    }
  }

  /// Signed distance of card [i] from the front, wrapped to the nearest side.
  double _offset(int i) {
    var o = (i - _pos) % _n;
    if (o > _n / 2) o -= _n;
    if (o < -_n / 2) o += _n;
    return o;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final n = _n;
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) => _offset(b).abs().compareTo(_offset(a).abs()));
    final cur = widget.items[_index.clamp(0, n - 1)];
    return Column(
      children: [
        _Head(style: s, seeAll: true),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => _drag = 0,
          onHorizontalDragUpdate: (d) => _drag += d.delta.dx,
          onHorizontalDragEnd: (_) {
            if (_drag.abs() > 36) _go(_index + (_drag < 0 ? 1 : -1));
            _drag = 0;
          },
          child: SizedBox(
            height: _Deck.height + 4,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(3, 2, 1 / 980),
              child: AnimatedBuilder(
                animation: Listenable.merge([_enter, _activation]),
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [for (final i in order) _card(i, s)],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // The title and tags of the card in front, each change rising in.
        SizedBox(
          height: 92,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: _ease,
            transitionBuilder: (child, anim) {
              final incoming = child.key == ValueKey(cur.artwork.id);
              if (!incoming) {
                // The old text is gone in the first moments of the change, so
                // the two never sit on top of each other.
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: anim,
                    curve: const Interval(.7, 1),
                  ),
                  child: child,
                );
              }
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: anim,
                  curve: const Interval(.25, 1),
                ),
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, .6),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            layoutBuilder: (cur, prev) => Stack(
              alignment: Alignment.topCenter,
              children: [...prev, ?cur],
            ),
            child: _Info(key: ValueKey(cur.artwork.id), scan: cur, style: s),
          ),
        ),
        const SizedBox(height: 16),
        _Dots(count: n, index: _index, style: s, onTap: _go),
      ],
    );
  }

  Widget _card(int i, HomeStyle s) {
    final o = _offset(i);
    final base = _Pose.at(o);
    // The fan-out: further cards leave the stack a little later.
    final delay = const [0.0, .08, .16, .16][o.abs().round().clamp(0, 3)];
    final f = _ease.transform(
      ((_enter.value - delay) / (1 - delay)).clamp(0.0, 1.0),
    );
    final pose = _Pose.lerp(_Pose.stacked, base, f);
    final front = i == _index;
    final scan = widget.items[i];
    // The move is the outer layer and the fade the inner one: a tap is
    // accepted where the card is drawn, not where it started.
    return Positioned(
      top: 14,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.translationValues(pose.x, pose.y, pose.z)
          ..rotateY(pose.turn)
          ..scaleByDouble(pose.scale, pose.scale, 1, 1),
        child: IgnorePointer(
          // A card that is not showing should not take a tap meant for another.
          ignoring: pose.fade < .05,
          child: Opacity(
            opacity: pose.fade.clamp(0.0, 1.0),
            child: _DeckCard(
              scan: scan,
              style: s,
              front: front,
              darken: pose.dark,
              activation: _activation,
              onTap: () {
                if (front) {
                  context.openArtwork(scan.artwork.id);
                } else {
                  _go(i);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One card of the deck.
class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.scan,
    required this.style,
    required this.front,
    required this.darken,
    required this.activation,
    required this.onTap,
  });

  final _Scan scan;
  final HomeStyle style;
  final bool front;

  /// How much the card is dimmed for sitting behind, 0–1.
  final double darken;
  final Animation<double> activation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = scan.artwork;
    final s = style;
    return Tappable(
      onTap: onTap,
      semanticLabel:
          '${a.semanticLabel}, scanned ${DateLabels.ago(scan.entry.at)}',
      pressedScale: .98,
      child: Container(
        width: _Deck.cardW,
        height: _Deck.cardH,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: s.line),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.55),
              offset: const Offset(0, 26),
              blurRadius: 34,
              spreadRadius: -22,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScale(
              scale: front ? 1.02 : 1.12,
              duration: const Duration(milliseconds: 1400),
              curve: const Cubic(.2, .8, .2, 1),
              child: Image(
                image: ResizeImage.resizeIfNeeded(
                  560,
                  null,
                  a.image.provider(),
                ),
                fit: BoxFit.cover,
                alignment: a.heroFocus,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
            ),
            // A soft shade across the top, so the time sits cleanly on the picture.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x590A0806), Color(0x000A0806)],
                  stops: [0, .28],
                ),
              ),
            ),
            if (darken > .001)
              ColoredBox(color: Color.fromRGBO(0, 0, 0, darken)),
            // Scanned just now: brackets, the sweep of light, the ring.
            AnimatedBuilder(
              animation: activation,
              builder: (context, _) {
                final t = front ? activation.value * 1.6 : 0.0; // seconds
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: front ? ((t - .2) / .4).clamp(0.0, 1.0) : 0,
                      child: const CustomPaint(painter: _BracketsPainter()),
                    ),
                    if (front) _Sweep(t: t),
                  ],
                );
              },
            ),
            Positioned(
              top: 13,
              left: 13,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEBF7F2EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateLabels.ago(scan.entry.at).toUpperCase(),
                  style: AppTypography.sans(
                    10,
                    weight: FontWeight.w700,
                    tracking: .1,
                  ).copyWith(color: const Color(0xFF2B2420)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A band of light that passes once down the picture.
class _Sweep extends StatelessWidget {
  const _Sweep({required this.t});

  /// Seconds since the card came forward.
  final double t;

  @override
  Widget build(BuildContext context) {
    final u = ((t - .15) / 1.5).clamp(0.0, 1.0);
    if (u <= 0 || u >= 1) return const SizedBox.shrink();
    final eased = const Cubic(.45, 0, .55, 1).transform(u);
    final opacity = u < .15 ? u / .15 : (u > .85 ? (1 - u) / .15 : 1.0);
    return Transform.translate(
      offset: Offset(0, -90 + (_Deck.cardH + 90) * eased),
      child: Align(
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: opacity,
          child: const SizedBox(
            height: 90,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00F0D9A6),
                    Color(0x52F0D9A6),
                    Color(0x00F0D9A6),
                  ],
                  stops: [0, .7, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The four scan brackets inset on the front card.
class _BracketsPainter extends CustomPainter {
  const _BracketsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    const arm = 22.0, rad = 10.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE0C17E);
    Path corner(Offset c, double dx, double dy) => Path()
      ..moveTo(c.dx, c.dy + dy * arm)
      ..lineTo(c.dx, c.dy + dy * rad)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + dx * rad, c.dy)
      ..lineTo(c.dx + dx * arm, c.dy);
    canvas
      ..drawPath(corner(r.topLeft, 1, 1), paint)
      ..drawPath(corner(r.topRight, -1, 1), paint)
      ..drawPath(corner(r.bottomLeft, 1, -1), paint)
      ..drawPath(corner(r.bottomRight, -1, -1), paint);
  }

  @override
  bool shouldRepaint(_BracketsPainter old) => false;
}

/// Title, artist and tags for the card in front.
class _Info extends StatelessWidget {
  const _Info({super.key, required this.scan, required this.style});

  final _Scan scan;
  final HomeStyle style;

  @override
  Widget build(BuildContext context) {
    final a = scan.artwork;
    final s = style;
    Widget tag(String text, {bool gold = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gold ? s.gold.withValues(alpha: .45) : s.line,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.sans(
          11,
          weight: FontWeight.w600,
        ).copyWith(color: gold ? s.gold : s.ink),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            a.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              20,
              weight: FontWeight.w700,
              tracking: -.02,
            ).copyWith(color: s.ink),
          ),
          const SizedBox(height: 4),
          Text(
            '${a.artist} · ${a.year}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              12.5,
              weight: FontWeight.w500,
            ).copyWith(color: s.muted),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: tag(a.movement, gold: true)),
              const SizedBox(width: 7),
              Flexible(child: tag('${a.museum}, ${a.city}')),
            ],
          ),
        ],
      ),
    );
  }
}

/// The dots under the deck; the active one stretches and turns gold.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.style,
    required this.onTap,
  });

  final int count;
  final int index;
  final HomeStyle style;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: const Cubic(.2, .8, .2, 1),
                width: i == index ? 28 : 7,
                height: 7,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: i == index ? s.gold : s.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyScans extends StatelessWidget {
  const _EmptyScans({required this.onScan, required this.style});

  final VoidCallback onScan;
  final HomeStyle style;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: CustomPaint(
        painter: _DashedRRect(color: s.line, radius: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
          decoration: BoxDecoration(
            color: s.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // A little empty picture frame.
              Container(
                width: 64,
                height: 80,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: s.ground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: s.line, width: 2),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: s.ground,
                    border: Border.all(color: s.line),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your gallery is waiting',
                textAlign: TextAlign.center,
                style: AppTypography.serif(
                  22,
                  weight: FontWeight.w700,
                ).copyWith(color: s.ink),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  'Paintings you scan will appear here with their stories.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    13,
                    weight: FontWeight.w500,
                    height: 1.45,
                  ).copyWith(color: s.muted),
                ),
              ),
              const SizedBox(height: 14),
              Tappable(
                onTap: onScan,
                semanticLabel: 'Scan your first painting',
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.deep,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    'Scan your first painting',
                    style: AppTypography.sans(
                      13.5,
                      weight: FontWeight.w700,
                    ).copyWith(color: s.onDeep),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 1px dashed rounded rectangle.
class _DashedRRect extends CustomPainter {
  const _DashedRRect({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(.5),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect old) =>
      old.color != color || old.radius != radius;
}
