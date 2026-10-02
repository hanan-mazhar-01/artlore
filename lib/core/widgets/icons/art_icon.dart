import 'package:flutter/widgets.dart';

import 'art_icons.dart';
import 'svg_path.dart';

/// Draws an [ArtIconData] with the design's thin, round-capped strokes.
class ArtIcon extends StatelessWidget {
  const ArtIcon(
    this.icon, {
    super.key,
    this.size = 18,
    this.color,
    this.strokeWidth = 1.6,
    this.filled = false,
    this.semanticLabel,
  });

  final ArtIconData icon;

  /// Rendered width; height follows the icon's viewBox aspect.
  final double size;
  final Color? color;
  final double strokeWidth;

  /// Also fill the stroked outline (e.g. a saved bookmark).
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color!;
    final aspect = icon.viewBox.width / icon.viewBox.height;
    final painted = CustomPaint(
      size: Size(size, size / aspect),
      painter: _ArtIconPainter(icon, c, strokeWidth, filled),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: painted);
    return Semantics(label: semanticLabel, child: painted);
  }
}

class _ArtIconPainter extends CustomPainter {
  _ArtIconPainter(this.icon, this.color, this.strokeWidth, this.filled);

  final ArtIconData icon;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / icon.viewBox.width;
    canvas.save();
    canvas.scale(scale);
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    for (final d in icon.strokes) {
      final path = SvgPath.parse(d);
      if (filled) canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
    for (final d in icon.fills) {
      canvas.drawPath(SvgPath.parse(d), fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArtIconPainter old) =>
      old.icon != icon ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.filled != filled;
}
