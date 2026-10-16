import 'package:flutter/widgets.dart';

import '../../theme/app_motion.dart';

/// The two-tone scan mark: four white viewfinder corners around a
/// landscape picture, with no dark outlines. Drawn as vector paths on a 640 × 640 grid, no background.
///
/// Loops the reference animation (83 frames, 1.66 s): the corners hold, pinch
/// in, then spring slightly past rest; the sun slides out left turning
/// orange, and a fresh one glides in from the right.
class ScanArtIcon extends StatefulWidget {
  const ScanArtIcon({
    super.key,
    this.size = 24,
    this.animate = true,
    this.cornerColor = const Color(0xFFFFFFFF),
  });

  final double size;
  final bool animate;

  /// Colour of the four viewfinder corners.
  final Color cornerColor;

  @override
  State<ScanArtIcon> createState() => _ScanArtIconState();
}

class _ScanArtIconState extends State<ScanArtIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1660),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final run = widget.animate && !AppMotion.reduced(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _ScanArtPainter(_c, widget.cornerColor),
        ),
      ),
    );
  }
}

/// Piecewise-linear lookup through measured (frame, value) keyframes.
double _keys(List<(double, double)> k, double f) {
  if (f <= k.first.$1) return k.first.$2;
  for (var i = 1; i < k.length; i++) {
    if (f <= k[i].$1) {
      final (f0, v0) = k[i - 1];
      final (f1, v1) = k[i];
      return v0 + (v1 - v0) * ((f - f0) / (f1 - f0));
    }
  }
  return k.last.$2;
}

class _ScanArtPainter extends CustomPainter {
  _ScanArtPainter(this.progress, this.cornerColor) : super(repaint: progress);

  final Animation<double> progress;
  final Color cornerColor;

  /// Corner scale about the icon centre, by frame.
  static const _cornerScale = [
    (0.0, 1.0),
    (41.0, 1.0),
    (50.0, .90),
    (60.0, .84),
    (72.0, .98),
    (82.0, 1.05),
    (83.0, 1.0),
  ];

  /// Sun centre x by frame: out to the left, gone, back in from the right.
  static const _sunX = [
    (0.0, 356.0),
    (3.0, 344.0),
    (6.0, 314.0),
    (9.0, 275.0),
    (12.0, 234.0),
    (15.0, 185.0),
    (28.0, 480.0),
    (30.0, 432.0),
    (33.0, 409.0),
    (36.0, 376.0),
    (39.0, 357.0),
    (42.0, 356.0),
  ];

  static const _sky = Color(0xFFD4DCFA);
  static const _blue = Color(0xFF2BA3CC);
  static const _teal = Color(0xFF67CDD2);
  static const _sun = Color(0xFFFFCE55);
  static const _sunSet = Color(0xFFFF8C00);

  Path _corner(Offset start, Offset elbowStart, Offset elbowEnd, Offset end) {
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(elbowStart.dx, elbowStart.dy)
      ..quadraticBezierTo(
        // The elbow control point is the square corner the arc rounds off.
        elbowStart.dx == start.dx ? elbowStart.dx : elbowEnd.dx,
        elbowStart.dy == start.dy ? elbowStart.dy : elbowEnd.dy,
        elbowEnd.dx,
        elbowEnd.dy,
      )
      ..lineTo(end.dx, end.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 640, size.height / 640);

    final corners = [
      _corner(
        const Offset(195, 122),
        const Offset(160, 122),
        const Offset(120, 162),
        const Offset(120, 195),
      ),
      _corner(
        const Offset(445, 122),
        const Offset(480, 122),
        const Offset(520, 162),
        const Offset(520, 195),
      ),
      _corner(
        const Offset(120, 445),
        const Offset(120, 485),
        const Offset(160, 525),
        const Offset(195, 525),
      ),
      _corner(
        const Offset(520, 445),
        const Offset(520, 485),
        const Offset(480, 525),
        const Offset(445, 525),
      ),
    ];
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final f = progress.value * 83;
    final cs = _keys(_cornerScale, f);
    canvas.save();
    canvas.translate(320, 320);
    canvas.scale(cs);
    canvas.translate(-320, -320);
    for (final c in corners) {
      canvas.drawPath(c, stroke(cornerColor, 38));
    }
    canvas.restore();

    // The picture — no outline, so it fills the whole frame area.
    const pic = Rect.fromLTWH(210, 212, 235, 233);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(pic, const Radius.circular(12)));
    Paint fill(Color c) => Paint()
      ..color = c
      ..isAntiAlias = true;
    canvas.drawRect(pic, fill(_sky));
    canvas.drawPath(
      Path()
        ..moveTo(324, 212)
        ..lineTo(322, 222)
        ..cubicTo(298, 285, 305, 370, 388, 435)
        ..lineTo(397, 445)
        ..lineTo(445, 445)
        ..lineTo(445, 212)
        ..close(),
      fill(const Color(0xFFFFFFFF)),
    );
    // Sun sits behind the hills; yellow when arriving, orange as it leaves.
    final onWayOut = f < 28;
    final sunColor = onWayOut
        ? Color.lerp(_sun, _sunSet, ((f - 6) / 3).clamp(0.0, 1.0))!
        : _sun;
    if (f <= 15 || f >= 28) {
      canvas.drawCircle(Offset(_keys(_sunX, f), 281), 22, fill(sunColor));
    }
    canvas.drawPath(
      Path()
        ..moveTo(315, 343)
        ..lineTo(355, 383)
        ..lineTo(398, 342)
        ..lineTo(445, 384)
        ..lineTo(445, 445)
        ..lineTo(397, 445)
        ..lineTo(388, 435)
        ..cubicTo(355, 420, 330, 395, 315, 343)
        ..close(),
      fill(_teal),
    );
    canvas.drawPath(
      Path()
        ..moveTo(210, 350)
        ..lineTo(265, 293)
        ..lineTo(315, 343)
        ..cubicTo(330, 395, 355, 420, 388, 435)
        ..lineTo(397, 445)
        ..lineTo(210, 445)
        ..close(),
      fill(_blue),
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScanArtPainter old) =>
      old.progress != progress || old.cornerColor != cornerColor;
}
