import 'package:flutter/widgets.dart';

import 'svg_path.dart';

/// The multicolour Google "G" on a white disc, so it reads on any button.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(size * .16),
        child: const CustomPaint(painter: _GoogleLogoPainter()),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const _parts = <(String, Color)>[
    (
      'M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53'
          '-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z',
      Color(0xFF4285F4),
    ),
    (
      'M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 '
          '1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z',
      Color(0xFF34A853),
    ),
    (
      'M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 '
          '8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z',
      Color(0xFFFBBC05),
    ),
    (
      'M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 '
          '7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z',
      Color(0xFFEA4335),
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // The glyph spans x 1–23 of a 24-unit box.
    canvas.scale(size.width / 24, size.height / 24);
    for (final (d, color) in _parts) {
      canvas.drawPath(
        SvgPath.parse(d),
        Paint()
          ..color = color
          ..isAntiAlias = true,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}
