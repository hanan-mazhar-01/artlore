import 'package:flutter/widgets.dart';

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
}
