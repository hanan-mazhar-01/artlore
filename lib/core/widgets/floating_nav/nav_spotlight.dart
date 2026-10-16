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
    this.breath,
  }) : super(repaint: breath == null ? progress : Listenable.merge([progress, breath]));

  final Animation<double> progress;

  /// 0 → 1 → 0 on a slow loop: the beam dims a little and brightens again.
  final Animation<double>? breath;
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

    // The cone. In the mock-up's nav it is a lamp's beam: narrow where it
    // leaves the bar and opening out as it falls, fading away. (The earlier
    // sizing keeps its near-rectangular beam.)
    final cx = m.centerOf(motion.position(t));
    final top = m.barHeight * .5;
    final coneWidth = m.mock ? m.barWidth * 1.065 : m.barWidth;
    final topHalf = m.mock ? coneWidth * .36 : m.barWidth * .465;
    final bottomHalf = m.mock ? coneWidth * .5 : m.barWidth * .485;
    final beam = Path()
      ..moveTo(cx - topHalf, top)
      ..lineTo(cx + topHalf, top)
      ..lineTo(cx + bottomHalf, m.coneHeight)
      ..lineTo(cx - bottomHalf, m.coneHeight)
      ..close();
    final breathe = Curves.easeInOut.transform(breath?.value ?? 0);
    final strength = motion.beam(t) *
        (m.mock ? .8 - .35 * breathe : 1 - .4375 * breathe);
    canvas.drawPath(
      beam,
      Paint()
        ..isAntiAlias = true
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          m.height * (m.mock ? .008 : .02),
        )
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: m.mock
              ? [lamp.withValues(alpha: .30 * strength), lamp.withValues(alpha: 0)]
              : [
                  lamp.withValues(alpha: .5 * strength),
                  lamp.withValues(alpha: .2 * strength),
                  lamp.withValues(alpha: 0),
                ],
          stops: m.mock ? const [0, 1] : const [0, .5, 1],
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
