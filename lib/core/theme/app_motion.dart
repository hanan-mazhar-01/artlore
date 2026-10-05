import 'package:flutter/material.dart';

/// Motion language: slow, cinematic and subtle. Curves mirror the design's
/// cubic-beziers so transitions feel identical.
abstract final class AppMotion {
  /// `cubic-bezier(.2,.7,.2,1)` — the house curve for reveals and frames.
  static const reveal = Cubic(.2, .7, .2, 1);

  /// `cubic-bezier(.2,.8,.2,1)` — bottom sheets.
  static const sheet = Cubic(.2, .8, .2, 1);

  /// `cubic-bezier(.25,.8,.2,1)` — Look Closer camera moves.
  static const glide = Cubic(.25, .8, .2, 1);

  /// `cubic-bezier(.3,.8,.3,1)` — toggle knobs.
  static const knob = Cubic(.3, .8, .3, 1);

  /// Modern card zoom / expand curves.
  static const cardCurve = Cubic(0.12, 0.98, 0.24, 1.0);
  static const cardReverseCurve = Cubic(0.24, 1.0, 0.12, 0.98);

  static const fast = Duration(milliseconds: 400);
  static const medium = Duration(milliseconds: 600);
  static const page = Duration(milliseconds: 700);
  static const slow = Duration(milliseconds: 1200);

  /// True when the user (or OS) asked for calmer motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d], or a near-instant duration when motion is reduced.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? const Duration(milliseconds: 1) : d;

  /// Curved RectTween matching the luxury easing of card expansions.
  static RectTween rectTween(Rect? begin, Rect? end) =>
      CurvedRectTween(begin: begin, end: end, curve: cardCurve);

  /// High-end Hero flight shuttle that smoothly animates border-radii
  /// between a card's silhouette and full-bleed header without hard jumps.
  static Widget heroShuttle({
    required Animation<double> animation,
    required HeroFlightDirection flightDirection,
    required BuildContext fromHeroContext,
    required BuildContext toHeroContext,
    BorderRadius? startRadius,
    BorderRadius? endRadius,
  }) {
    final Hero hero = (flightDirection == HeroFlightDirection.push
        ? toHeroContext.widget
        : fromHeroContext.widget) as Hero;
    final r1 = startRadius ?? BorderRadius.zero;
    final r2 = endRadius ?? BorderRadius.zero;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final currentRadius =
            BorderRadius.lerp(r1, r2, animation.value) ?? BorderRadius.zero;
        return Material(
          type: MaterialType.transparency,
          child: ClipRRect(
            borderRadius: currentRadius,
            child: hero.child,
          ),
        );
      },
    );
  }
}

/// A [RectTween] that evaluates over a [Curve] rather than a linear slope.
class CurvedRectTween extends RectTween {
  CurvedRectTween({
    super.begin,
    super.end,
    this.curve = const Cubic(0.12, 0.98, 0.24, 1.0),
  });

  final Curve curve;

  @override
  Rect? lerp(double t) => super.lerp(curve.transform(t));
}

