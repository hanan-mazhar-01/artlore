import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Camera moves for Look Closer, ported from the design's maths: the canvas
/// fills the viewport height, and focusing a detail zooms to 1.6× with the
/// point placed in the upper part of the screen, above the detail sheet.
class LookCloserCamera {
  const LookCloserCamera({required this.viewport, required this.aspect});

  final Size viewport;

  /// Image width ÷ height.
  final double aspect;

  static const focusScale = 1.6;

  /// The design's viewport was 620pt tall; offsets scale from it.
  double get _k => viewport.height / 620;

  Size get canvas => Size(viewport.height * aspect, viewport.height);

  Matrix4 overview() => _matrix((viewport.width - canvas.width) / 2, 0, 1);

  /// Transform that brings the point ([x], [y] as image fractions) into view.
  Matrix4 focus(double x, double y) {
    const s = focusScale;
    final w = canvas.width * s, h = canvas.height * s;
    final tx = w <= viewport.width
        ? (viewport.width - w) / 2
        : _clamp(viewport.width / 2 - x * w, viewport.width - w, 0);
    final ty = _clamp(230 * _k - y * h, viewport.height - 120 * _k - h, 0);
    return _matrix(tx, ty, s);
  }

  static double _clamp(double v, double lo, double hi) =>
      math.min(hi, math.max(lo, v));

  static Matrix4 _matrix(double tx, double ty, double s) => Matrix4.identity()
    ..translateByDouble(tx, ty, 0, 1)
    ..scaleByDouble(s, s, 1, 1);
}
