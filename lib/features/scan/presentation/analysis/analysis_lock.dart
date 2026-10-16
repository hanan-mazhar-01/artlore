import 'package:flutter/widgets.dart';

/// The opening beat of the analysis, with no words: a focus ring hunts across
/// the picture, settles, and then a gold outline draws itself round the frame
/// while four round nodes pop onto its corners — the picture has been found.
/// After that the outline stays, breathing softly, while the reading goes on.
class AnalysisLock extends StatefulWidget {
  const AnalysisLock({super.key, required this.color, this.visible = true});

  final Color color;

  /// False once the glide to the painting's page begins.
  final bool visible;

  @override
  State<AnalysisLock> createState() => _AnalysisLockState();
}

class _AnalysisLockState extends State<AnalysisLock>
    with TickerProviderStateMixin {
  late final AnimationController _lock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2700),
  )..forward();
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _lock.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOut,
        opacity: widget.visible ? 1 : 0,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _LockPainter(
              lock: _lock,
              breath: _breath,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _LockPainter extends CustomPainter {
  _LockPainter({required this.lock, required this.breath, required this.color})
    : super(repaint: Listenable.merge([lock, breath]));

  final Animation<double> lock;
  final Animation<double> breath;
  final Color color;

  // The timeline, in seconds, as in the scan mock-up: the focus ring hunts for
  // 1.5s, then the outline draws over 1.05s while the nodes pop (each .5s, .22s
  // apart).
  static const _total = 2.7;
  static const _huntEnd = 1.5;
  static const _drawEnd = 1.5 + 1.05;

  @override
  void paint(Canvas canvas, Size size) {
    final t = lock.value * _total;
    const m = 10.0;
    final r = Rect.fromLTWH(m, m, size.width - 2 * m, size.height - 2 * m);

    // 1 · the focus ring hunts. Keyframes as in the mock-up: it arrives large
    // at one spot, settles, slides to another, then shrinks away.
    if (t < _huntEnd) {
      final u = t / _huntEnd; // 0 → 1
      Offset at(double dx, double dy) => r.center + Offset(dx, dy);
      var pos = at(-30, 40);
      var scale = 1.0;
      var alpha = 0.0;
      if (u < .3) {
        final k = u / .3;
        scale = 1.5 - .5 * Curves.easeOut.transform(k);
        alpha = Curves.easeOut.transform(k);
      } else if (u < .6) {
        final k = (u - .3) / .3;
        pos = Offset.lerp(
          at(-30, 40),
          at(24, -22),
          Curves.easeInOut.transform(k),
        )!;
        alpha = 1;
      } else {
        final k = (u - .6) / .4;
        pos = Offset.lerp(
          at(24, -22),
          r.center,
          Curves.easeInOut.transform(k),
        )!;
        scale = 1 - .2 * Curves.easeInOut.transform(k);
        alpha = 1 - Curves.easeInOut.transform(k);
      }
      final half = 33.0 * scale;
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .85 * alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: half * 2, height: half * 2),
          Radius.circular(18 * scale),
        ),
        ring,
      );
      final tick = Paint()
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .85 * alpha);
      canvas
        ..drawLine(
          Offset(pos.dx, pos.dy - half - 5),
          Offset(pos.dx, pos.dy - half + 1),
          tick,
        )
        ..drawLine(
          Offset(pos.dx - half - 5, pos.dy),
          Offset(pos.dx - half + 1, pos.dy),
          tick,
        );
    }

    // 2 · the outline draws itself round the frame, clockwise from the top.
    final draw = const Cubic(
      .5,
      0,
      .2,
      1,
    ).transform(((t - _huntEnd) / (_drawEnd - _huntEnd)).clamp(0.0, 1.0));
    const rad = 9.0;
    final outline = Path()
      ..moveTo(r.center.dx, r.top)
      ..lineTo(r.right - rad, r.top)
      ..arcToPoint(
        Offset(r.right, r.top + rad),
        radius: const Radius.circular(rad),
      )
      ..lineTo(r.right, r.bottom - rad)
      ..arcToPoint(
        Offset(r.right - rad, r.bottom),
        radius: const Radius.circular(rad),
      )
      ..lineTo(r.left + rad, r.bottom)
      ..arcToPoint(
        Offset(r.left, r.bottom - rad),
        radius: const Radius.circular(rad),
      )
      ..lineTo(r.left, r.top + rad)
      ..arcToPoint(
        Offset(r.left + rad, r.top),
        radius: const Radius.circular(rad),
      )
      ..close();
    if (draw > 0) {
      final metric = outline.computeMetrics().first;
      final drawn = metric.extractPath(0, metric.length * draw);
      final glow = .6 + .4 * Curves.easeInOut.transform(breath.value);
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: .28 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    // 3 · four nodes pop onto the corners, each .5s, .22s apart, overshooting.
    final corners = [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft];
    for (var i = 0; i < 4; i++) {
      final k = ((t - _huntEnd - i * .22) / .5).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final pop = const Cubic(.2, 1.5, .4, 1).transform(k);
      final radius = 7 * pop;
      canvas
        ..drawCircle(
          corners[i],
          radius + 5,
          Paint()
            ..color = color.withValues(alpha: .55 * k)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        )
        ..drawCircle(
          corners[i],
          radius,
          Paint()..color = const Color(0xFF1A1612),
        )
        ..drawCircle(
          corners[i],
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = color,
        );
    }
  }

  @override
  bool shouldRepaint(_LockPainter old) => old.color != color;
}

/// The reading beam: a soft band of light with a bright lower edge that sweeps
/// down the picture again and again, as in the mock-up, and — alongside it —
/// small points of light that wink on across the picture.
class ReadBeam extends StatefulWidget {
  const ReadBeam({super.key, this.delay = Duration.zero});

  /// Wait this long before the beam fades in (the lock-on goes first).
  final Duration delay;

  @override
  State<ReadBeam> createState() => _ReadBeamState();
}

class _ReadBeamState extends State<ReadBeam> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2100),
  );
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  // left %, top %, delay (s) — the same seven as the mock-up.
  static const _spots = [
    (.14, .20, .10),
    (.68, .14, .35),
    (.42, .46, .60),
    (.82, .58, .85),
    (.24, .72, 1.10),
    (.58, .84, 1.30),
    (.08, .52, .50),
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) return;
      _in.forward();
      _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _in.dispose();
    super.dispose();
  }

  /// The mock-up's `feature` keyframes: 0% nothing, 30% full and larger, 60%
  /// dimmer and smaller, 100% nothing.
  static (double, double) _feature(double u) {
    if (u < .3) return (u / .3, 1.3 * u / .3);
    if (u < .6) {
      final k = (u - .3) / .3;
      return (1 - .65 * k, 1.3 - .5 * k);
    }
    final k = (u - .6) / .4;
    return (.35 * (1 - k), .8 * (1 - k));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _in,
        child: LayoutBuilder(
          builder: (context, box) {
            final band = box.maxHeight * .36;
            return AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final sweep = const Cubic(.45, 0, .55, 1).transform(_c.value);
                final top = -band + (box.maxHeight + band) * sweep;
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: top,
                      height: band,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00F0D9A6),
                              Color(0x61F0D9A6),
                              Color(0x00F0D9A6),
                            ],
                            stops: [0, .78, 1],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFF6E2B3),
                              width: 2,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xB3E2C27F),
                              blurRadius: 24,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final (x, y, d) in _spots)
                      Builder(
                        builder: (context) {
                          final u = (((_c.value * 2.1 - d) / 2.1) % 1 + 1) % 1;
                          final (a, sc) = _feature(u);
                          return Positioned(
                            left: box.maxWidth * x - 2.5,
                            top: box.maxHeight * y - 2.5,
                            child: Opacity(
                              opacity: a.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: sc.clamp(0.0, 1.4),
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF6E2B3),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFF6E2B3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(width: 5, height: 5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
