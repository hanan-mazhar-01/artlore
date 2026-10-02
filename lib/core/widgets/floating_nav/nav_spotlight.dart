import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'art_nav_item.dart';

/// Where the light is between two selections.
///
/// The cone glides from the old item to the new one; the lamp bars and icons
/// cross-fade in place — the same choreography as the reference.
@immutable
class SpotlightMotion {
  const SpotlightMotion._(this.fromPos, this.to, this.fromWeights);

  /// Resting on [index].
  factory SpotlightMotion.at(int index, int count) => SpotlightMotion._(
    index.toDouble(),
    index,
    [for (var i = 0; i < count; i++) i == index ? 1.0 : 0.0],
  );

  final double fromPos;
  final int to;
  final List<double> fromWeights;

  static const glide = Curves.easeInOutCubic;

  /// Cone position at progress [t].
  double position(double t) => lerpDouble(fromPos, to, glide.transform(t))!;

  /// How lit item [i] is (bar opacity, icon brightness) at [t].
  double weight(int i, double t) =>
      lerpDouble(fromWeights[i], i == to ? 1.0 : 0.0, t)!;

  /// The beam softens while it travels, then settles at full strength.
  double beam(double t) => fromPos == to ? 1 : 1 - .35 * math.sin(math.pi * t);

  /// Starts a new move from wherever the light is right now, so an
  /// interrupted animation never jumps.
  SpotlightMotion retarget(int next, double t) => SpotlightMotion._(
    position(t),
    next,
    [for (var i = 0; i < fromWeights.length; i++) weight(i, t)],
  );

  /// Distance of the current move, in slots.
  double get distance => (to - fromPos).abs();
}

/// Paints the lamp bars and the falling cone of light inside the pill.
class NavSpotlightPainter extends CustomPainter {
  NavSpotlightPainter({
    required this.progress,
    required this.motion,
    required this.metrics,
    required this.lamp,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final SpotlightMotion motion;
  final FloatingNavMetrics metrics;
  final Color lamp;

  @override
  void paint(Canvas canvas, Size size) {
    final m = metrics;
    final t = progress.value;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(m.height / 2),
      ),
    );

    // The cone: a near-rectangular beam, fading as it falls.
    final cx = m.centerOf(motion.position(t));
    final top = m.barHeight * .5;
    final topHalf = m.barWidth * .465, bottomHalf = m.barWidth * .485;
    final beam = Path()
      ..moveTo(cx - topHalf, top)
      ..lineTo(cx + topHalf, top)
      ..lineTo(cx + bottomHalf, m.coneHeight)
      ..lineTo(cx - bottomHalf, m.coneHeight)
      ..close();
    final strength = motion.beam(t);
    canvas.drawPath(
      beam,
      Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, m.height * .02)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lamp.withValues(alpha: .5 * strength),
            lamp.withValues(alpha: .2 * strength),
            lamp.withValues(alpha: 0),
          ],
          stops: const [0, .5, 1],
        ).createShader(Rect.fromLTRB(0, top, size.width, m.coneHeight)),
    );

    // The lamp bars, cross-fading in place.
    final bar = Paint();
    for (var i = 0; i < m.count; i++) {
      final w = motion.weight(i, t);
      if (w < .01) continue;
      bar.color = lamp.withValues(alpha: w);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(m.centerOf(i.toDouble()), m.barHeight / 2 + .5),
            width: m.barWidth,
            height: m.barHeight,
          ),
          Radius.circular(m.barHeight / 2),
        ),
        bar,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(NavSpotlightPainter old) =>
      old.motion != motion || old.metrics != metrics || old.lamp != lamp;
}
