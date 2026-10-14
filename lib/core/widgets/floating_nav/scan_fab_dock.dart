import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../extensions/context_x.dart';
import 'scan_fab.dart';

/// Joins the scan button to the end of the nav pill so the two read as one
/// liquid shape: a ring in the pill's colour around the button, and a neck
/// whose sides are smooth concave arcs tangent to both the pill's rounded end
/// and the ring. The button itself is [ScanFab], untouched.
///
/// Lay it out directly after the pill; the neck reaches back under its end.
class ScanFabDock extends StatelessWidget {
  const ScanFabDock({
    super.key,
    required this.diameter,
    required this.pillHeight,
    required this.onTap,
  });

  static const _ring = 5.0;

  final double diameter;
  final double pillHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fill = p.navPill;
    // Same hairline as the pill's rim.
    final rim = context.isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: .16)
        : p.accentAlpha(.45);
    final shadow = BoxShadow(
      color: p.shadow.withValues(alpha: p.shadow.a * .5),
      offset: Offset(pillHeight * .05, pillHeight * .2),
      blurRadius: pillHeight * .6,
    );

    final ringDiameter = diameter + _ring * 2;
    final gap = pillHeight * .2; // clear space between pill end and ring
    final pillR = pillHeight / 2;
    final ringR = ringDiameter / 2;
    return SizedBox(
      width: gap + ringDiameter,
      height: ringDiameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // From the pill's end-cap centre to the ring's centre.
          Positioned(
            left: -pillR,
            top: 0,
            bottom: 0,
            width: pillR + gap + ringR,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _NeckPainter(
                  fill: fill,
                  rim: rim,
                  shadow: shadow,
                  pillRadius: pillR,
                  ringRadius: ringR,
                  centreDistance: pillR + gap + ringR,
                ),
              ),
            ),
          ),
          Positioned(
            left: gap,
            top: 0,
            child: Container(
              width: ringDiameter,
              height: ringDiameter,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: rim, width: .8),
                boxShadow: [shadow],
              ),
              child: ScanFab(diameter: diameter, onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the neck between two circles A (the pill's end cap, centre at the
/// left edge of the canvas) and B (the ring, centre at the right edge).
///
/// A fillet circle of radius [_fillet] sits tangent to both, above and below.
/// The neck is the quadrilateral A-centre, fillet, B-centre, fillet, minus the
/// two fillet discs — which leaves exactly the smooth waist of a metaball.
class _NeckPainter extends CustomPainter {
  const _NeckPainter({
    required this.fill,
    required this.rim,
    required this.shadow,
    required this.pillRadius,
    required this.ringRadius,
    required this.centreDistance,
  });

  final Color fill;
  final Color rim;
  final BoxShadow shadow;
  final double pillRadius;
  final double ringRadius;
  final double centreDistance;

  static const _fillet = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final a = Offset(0, cy);
    final b = Offset(centreDistance, cy);

    // Fillet centre, tangent externally to both circles.
    final da = pillRadius + _fillet;
    final db = ringRadius + _fillet;
    final x = (da * da - db * db + centreDistance * centreDistance) /
        (2 * centreDistance);
    final y2 = da * da - x * x;
    if (y2 <= 0) return;
    final y = math.sqrt(y2);
    final top = Offset(x, cy - y);
    final bottom = Offset(x, cy + y);

    final quad = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(top.dx, top.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..close();
    Path disc(Offset c) =>
        Path()..addOval(Rect.fromCircle(center: c, radius: _fillet));
    var neck = Path.combine(PathOperation.difference, quad, disc(top));
    neck = Path.combine(PathOperation.difference, neck, disc(bottom));

    // Soft shadow under the neck, matching the pill and ring. Kept out of the
    // pill and ring themselves so it never smudges their surfaces.
    var outside = Path()..addRect((Offset.zero & size).inflate(200));
    outside = Path.combine(
      PathOperation.difference,
      outside,
      Path()..addOval(Rect.fromCircle(center: a, radius: pillRadius)),
    );
    outside = Path.combine(
      PathOperation.difference,
      outside,
      Path()..addOval(Rect.fromCircle(center: b, radius: ringRadius)),
    );
    canvas.save();
    canvas.clipPath(outside);
    canvas.drawPath(
      neck.shift(shadow.offset),
      Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
    );
    canvas.restore();

    // Cover the pill's rim where the neck leaves its rounded end.
    canvas.save();
    canvas.clipPath(quad);
    canvas.drawCircle(a, pillRadius + 1, Paint()..color = fill);
    canvas.restore();

    canvas.drawPath(
      neck,
      Paint()
        ..color = fill
        ..isAntiAlias = true,
    );

    // Hairline along the two concave sides only.
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..isAntiAlias = true
      ..color = rim;
    for (final f in [top, bottom]) {
      final ta = a + (f - a) * (pillRadius / da);
      final tb = b + (f - b) * (ringRadius / db);
      final startAngle = math.atan2(ta.dy - f.dy, ta.dx - f.dx);
      final endAngle = math.atan2(tb.dy - f.dy, tb.dx - f.dx);
      var sweep = endAngle - startAngle;
      while (sweep > math.pi) {
        sweep -= 2 * math.pi;
      }
      while (sweep < -math.pi) {
        sweep += 2 * math.pi;
      }
      canvas.drawArc(
        Rect.fromCircle(center: f, radius: _fillet),
        startAngle,
        sweep,
        false,
        rimPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_NeckPainter old) =>
      old.fill != fill ||
      old.rim != rim ||
      old.pillRadius != pillRadius ||
      old.ringRadius != ringRadius ||
      old.centreDistance != centreDistance;
}
