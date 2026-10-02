import 'dart:ui';

/// Minimal SVG path-data parser (M L H V C S Q A Z, absolute and relative),
/// so ArtLore's icons are drawn from the exact paths in the design.
abstract final class SvgPath {
  static final _token = RegExp(
    r'[MmLlHhVvCcSsQqAaZz]|[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?',
  );
  static final _cache = <String, Path>{};

  /// Parses [data] once and caches the resulting [Path].
  static Path parse(String data) => _cache[data] ??= _parse(data);

  static Path _parse(String data) {
    final tokens = _token.allMatches(data).map((m) => m.group(0)!).toList();
    final path = Path();
    var i = 0;
    var cmd = 'M';
    var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
    double? cx2, cy2; // last cubic control point, for S

    bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
    double n() => double.parse(tokens[i++]);

    while (i < tokens.length) {
      if (isCmd(tokens[i])) cmd = tokens[i++];
      final rel = cmd.toLowerCase() == cmd;
      final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
      switch (cmd.toUpperCase()) {
        case 'M':
          x = ox + n();
          y = oy + n();
          path.moveTo(x, y);
          sx = x;
          sy = y;
          cmd = rel ? 'l' : 'L';
          cx2 = null;
        case 'L':
          x = ox + n();
          y = oy + n();
          path.lineTo(x, y);
          cx2 = null;
        case 'H':
          x = ox + n();
          path.lineTo(x, y);
          cx2 = null;
        case 'V':
          y = oy + n();
          path.lineTo(x, y);
          cx2 = null;
        case 'C':
          final x1 = ox + n(), y1 = oy + n();
          final x2 = ox + n(), y2 = oy + n();
          x = ox + n();
          y = oy + n();
          path.cubicTo(x1, y1, x2, y2, x, y);
          cx2 = x2;
          cy2 = y2;
        case 'S':
          final x1 = 2 * x - (cx2 ?? x);
          final y1 = 2 * y - (cy2 ?? y);
          final x2 = ox + n(), y2 = oy + n();
          x = ox + n();
          y = oy + n();
          path.cubicTo(x1, y1, x2, y2, x, y);
          cx2 = x2;
          cy2 = y2;
        case 'Q':
          final x1 = ox + n(), y1 = oy + n();
          x = ox + n();
          y = oy + n();
          path.quadraticBezierTo(x1, y1, x, y);
          cx2 = null;
        case 'A':
          final rx = n(), ry = n(), rot = n();
          final large = n() != 0, sweep = n() != 0;
          x = ox + n();
          y = oy + n();
          path.arcToPoint(
            Offset(x, y),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: large,
            clockwise: sweep,
          );
          cx2 = null;
        case 'Z':
          path.close();
          x = sx;
          y = sy;
          cx2 = null;
        default:
          i++;
      }
    }
    return path;
  }
}
