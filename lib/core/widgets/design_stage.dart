import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

/// Hosts an absolutely-positioned composition authored on the design's
/// 390pt frame and scales it uniformly to the space available, so collages
/// keep their exact proportions on every iPhone size.
class DesignStage extends StatelessWidget {
  const DesignStage({
    super.key,
    required this.height,
    required this.children,
    this.width = AppSpacing.designWidth,
    this.alignment = Alignment.center,
    this.clip = Clip.none,
  });

  final double width;
  final double height;
  final List<Widget> children;
  final Alignment alignment;
  final Clip clip;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: alignment,
      clipBehavior: clip,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }
}

/// Four corner brackets — the scanning frame and onboarding viewfinder.
class CornerBrackets extends StatelessWidget {
  const CornerBrackets({
    super.key,
    required this.color,
    this.size = 30,
    this.stroke = 2,
    this.radius = 10,
  });

  final Color color;
  final double size;
  final double stroke;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BracketPainter(color, size, stroke, radius),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter(this.color, this.len, this.stroke, this.radius);

  final Color color;
  final double len;
  final double stroke;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final h = stroke / 2;
    final r = radius;
    // Top-left, then mirror for the other three corners.
    final corner = Path()
      ..moveTo(h, len)
      ..lineTo(h, h + r)
      ..arcToPoint(Offset(h + r, h), radius: Radius.circular(r))
      ..lineTo(len, h);
    final w = size.width, hgt = size.height;
    final flips = [
      Matrix4.identity(),
      Matrix4.identity()
        ..translateByDouble(w, 0, 0, 1)
        ..scaleByDouble(-1, 1, 1, 1),
      Matrix4.identity()
        ..translateByDouble(0, hgt, 0, 1)
        ..scaleByDouble(1, -1, 1, 1),
      Matrix4.identity()
        ..translateByDouble(w, hgt, 0, 1)
        ..scaleByDouble(-1, -1, 1, 1),
    ];
    for (final m in flips) {
      canvas.drawPath(corner.transform(m.storage), paint);
    }
  }

  @override
  bool shouldRepaint(_BracketPainter old) =>
      old.color != color ||
      old.len != len ||
      old.stroke != stroke ||
      old.radius != radius;
}
