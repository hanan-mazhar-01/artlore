import 'package:flutter/painting.dart';

/// ArtLore type system: Cormorant Garamond for editorial voice,
/// Manrope for interface and metadata.
///
/// Styles carry no colour; text inherits ink from the theme and widgets tint
/// with `copyWith(color: ...)` from [AppPalette].
abstract final class AppTypography {
  static const serifFamily = 'Cormorant Garamond';
  static const sansFamily = 'Manrope';

  /// Serif at an arbitrary design size. [tracking] is in em, as in the design.
  static TextStyle serif(
    double size, {
    FontWeight weight = FontWeight.w400,
    bool italic = false,
    double? height,
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: size,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      letterSpacing: tracking * size,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Sans at an arbitrary design size. [tracking] is in em.
  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? height,
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: tracking * size,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // — Editorial (serif) —
  static final display = serif(50, weight: FontWeight.w500, height: .95);
  static final hero = serif(46, weight: FontWeight.w500, height: 1);
  static final title = serif(40, weight: FontWeight.w500, height: 1.02);
  static final pageTitle = serif(42, weight: FontWeight.w500, height: 1);
  static final heading = serif(26, weight: FontWeight.w500, height: 1.15);
  static final quote = serif(27, italic: true, height: 1.2);

  // — Interface (sans) —
  static final body = sans(15, height: 1.6);
  static final bodySmall = sans(14, height: 1.55);
  static final caption = sans(12, height: 1.4);
  static final metadata = sans(11, height: 1.35);
  static final tab = sans(10, weight: FontWeight.w600);
}
