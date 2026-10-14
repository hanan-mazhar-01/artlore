import 'package:flutter/widgets.dart';

import '../../extensions/context_x.dart';
import 'scan_fab.dart';

/// Extends the nav pill so the scan button sits inside its right end — one
/// continuous capsule, the gold button ringed in the pill's own cap.
///
/// Place it so its left edge is the pill's old cap centre (`pillWidth - h/2`).
/// It paints a body and a new rounded end
/// over the pill's old right cap (same fill and rim), then sets [ScanFab]
/// into that end.
class ScanFabDock extends StatelessWidget {
  const ScanFabDock({super.key, required this.pillHeight, required this.onTap});

  /// How much wider the capsule becomes to take the button.
  static double extraWidth(double pillHeight) => pillHeight * .62;

  /// Gold button diameter for a pill of this height.
  static double buttonDiameter(double pillHeight) => pillHeight * .74;

  final double pillHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rim = context.isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: .16)
        : p.accentAlpha(.45);
    final shadow = BoxShadow(
      color: p.shadow.withValues(alpha: p.shadow.a * .5),
      offset: Offset(pillHeight * .05, pillHeight * .2),
      blurRadius: pillHeight * .6,
    );
    final extra = extraWidth(pillHeight);
    final d = buttonDiameter(pillHeight);
    final ring = d + 8;
    final r = pillHeight / 2;
    // Local x = 0 is the pill's old cap centre, so the dock is `extra + r`
    // wide and its new cap is centred `extra` along — the button sits there.
    return SizedBox(
      width: extra + r,
      height: pillHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TailPainter(
                  fill: p.navPill,
                  rim: rim,
                  shadow: shadow,
                  radius: r,
                ),
              ),
            ),
          ),
          Positioned(
            left: extra - ring / 2,
            top: (pillHeight - ring) / 2,
            child: Container(
              width: ring,
              height: ring,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      (context.isDark
                              ? const Color(0xFFF3E4CF)
                              : const Color(0xFF2D2621))
                          .withValues(alpha: .5),
                  width: 1.5,
                ),
              ),
              child: ScanFab(diameter: d, onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the capsule's extension. Local x = 0 is the old cap's centre, so the
/// body starts inside the pill (where it is already full height).
class _TailPainter extends CustomPainter {
  const _TailPainter({
    required this.fill,
    required this.rim,
    required this.shadow,
    required this.radius,
  });

  final Color fill;
  final Color rim;
  final BoxShadow shadow;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final capCentre = Offset(size.width - radius, h / 2);
    final body = Path()
      ..addRect(Rect.fromLTRB(0, 0, capCentre.dx, h))
      ..addOval(Rect.fromCircle(center: capCentre, radius: radius));

    // Shadow only beyond the old pill, so it never smudges its surface.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(radius, -100, size.width + 100, h + 100));
    canvas.drawPath(
      body.shift(shadow.offset),
      Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
    );
    canvas.restore();

    canvas.drawPath(
      body,
      Paint()
        ..color = fill
        ..isAntiAlias = true,
    );

    // Hairline: top edge, around the new end, bottom edge — the same line the
    // pill carries.
    const w = .8;
    final rimPath = Path()
      ..moveTo(0, w / 2)
      ..lineTo(capCentre.dx, w / 2)
      ..arcTo(
        Rect.fromCircle(center: capCentre, radius: radius - w / 2),
        -1.5707963267948966,
        3.141592653589793,
        false,
      )
      ..lineTo(0, h - w / 2);
    canvas.drawPath(
      rimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..isAntiAlias = true
        ..color = rim,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.fill != fill || old.rim != rim || old.radius != radius;
}
