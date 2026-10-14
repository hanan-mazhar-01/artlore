import 'package:flutter/painting.dart';

/// ArtLore type system: Inter throughout — headings (the "serif" styles) and
/// interface alike.
///
/// Styles carry no colour; text inherits ink from the theme and widgets tint
/// with `copyWith(color: ...)` from [AppPalette].
abstract final class AppTypography {
  static const serifFamily = sansFamily;
  static const sansFamily = 'Inter';

  /// Heading style at an arbitrary *design* size. [tracking] is in em.
  ///
  /// The design sizes were drawn for a small-x-height display serif; Inter is
  /// much larger on the page at the same point size, so [headingSize]
  /// compresses them. Headings are never lighter than semi-bold.
  /// [italic] is accepted for call-site compatibility but the app renders
  /// upright type throughout.
  static TextStyle serif(
    double size, {
    FontWeight weight = FontWeight.w400,
    bool italic = false,
    double? height,
    double tracking = 0,
  }) {
    final fitted = headingSize(size);
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: fitted,
      fontWeight: weight.value < FontWeight.w600.value
          ? FontWeight.w600
          : weight,
      height: height,
      letterSpacing: tracking * fitted,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Maps a design heading size onto Inter: small sizes shrink slightly,
  /// large ones much more (44 → ~33, 28 → ~23, 22 → ~19).
  static double headingSize(double design) {
    if (design <= 18) return design * .92;
    return 17 + (design - 18) * .6;
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
  static final display = serif(50, weight: FontWeight.w700, height: 1.08);
  static final hero = serif(46, weight: FontWeight.w700, height: 1.1);
  static final title = serif(40, weight: FontWeight.w700, height: 1.12);
  static final pageTitle = serif(42, weight: FontWeight.w700, height: 1.12);
  static final heading = serif(26, weight: FontWeight.w700, height: 1.25);
  static final quote = serif(27, height: 1.35);

  // — Interface (sans) —
  static final body = sans(15, height: 1.6);
  static final bodySmall = sans(14, height: 1.55);
  static final caption = sans(12, height: 1.4);
  static final metadata = sans(11, height: 1.35);
  static final tab = sans(10, weight: FontWeight.w600);
}
