import 'package:flutter/painting.dart';

import 'app_palette.dart';

/// Elevation recipes. Shadow colour comes from the palette so light mode gets
/// warm, soft shadows instead of heavy black ones.
abstract final class AppShadows {
  /// Hero artwork — `0 30px 60px rgba(0,0,0,.5)`.
  static List<BoxShadow> artwork(AppPalette p) => [
    BoxShadow(color: p.shadow, offset: const Offset(0, 30), blurRadius: 60),
  ];

  /// Floating editorial card — `0 18px 40px rgba(0,0,0,.45)`.
  static List<BoxShadow> card(AppPalette p) => [
    BoxShadow(
      color: p.shadow.withValues(alpha: p.shadow.a * .9),
      offset: const Offset(0, 18),
      blurRadius: 40,
    ),
  ];

  /// Tilted collage pieces — `0 24px 50px rgba(0,0,0,.55)`.
  static List<BoxShadow> collage(AppPalette p) => [
    BoxShadow(
      color: p.shadow.withValues(alpha: p.shadow.a * 1.1),
      offset: const Offset(0, 24),
      blurRadius: 50,
    ),
  ];

  /// Bottom sheet — `0 -20px 50px rgba(0,0,0,.5)`.
  static List<BoxShadow> sheet(AppPalette p) => [
    BoxShadow(color: p.shadow, offset: const Offset(0, -20), blurRadius: 50),
  ];

  /// Soft gold halo, e.g. the scan tab button.
  static List<BoxShadow> goldHalo(AppPalette p, {double opacity = .22}) => [
    BoxShadow(color: p.accentAlpha(opacity), blurRadius: 30),
  ];

  /// Glowing gold line used by every scanning sweep.
  static List<BoxShadow> sweepGlow(AppPalette p) => [
    BoxShadow(color: p.accentAlpha(.6), blurRadius: 14, spreadRadius: 3),
  ];
}
