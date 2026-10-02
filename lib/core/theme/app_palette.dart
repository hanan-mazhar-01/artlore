import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colour roles for ArtLore, resolved per theme.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.deep,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.inverse,
    required this.onInverse,
    required this.inverseLink,
    required this.toggleOff,
    required this.knob,
    required this.danger,
    required this.scrim,
    required this.glass,
    required this.shadow,
    required this.navPill,
    required this.navIcon,
    required this.navLamp,
  });

  /// Page ground.
  final Color background;

  /// Raised card / sheet surface.
  final Color surface;

  /// Quieter surface used for editorial panels.
  final Color surfaceAlt;

  /// Darker-than-ground canvas used behind full-bleed artwork.
  final Color deep;

  /// Primary text.
  final Color ink;

  /// Secondary text, metadata and inactive navigation.
  final Color muted;

  /// Restrained gold accent.
  final Color accent;

  /// Solid pill buttons (ivory on dark, charcoal on light) and their ink.
  final Color inverse;
  final Color onInverse;
  final Color inverseLink;

  final Color toggleOff;

  /// Toggle knob.
  final Color knob;
  final Color danger;
  final Color scrim;

  /// Translucent fill for buttons floating over artwork.
  final Color glass;
  final Color shadow;

  /// Floating navigation: a mid-tone pill, resting icons a step darker,
  /// and the "lamp" light that marks the active item.
  final Color navPill;
  final Color navIcon;
  final Color navLamp;

  Color get onAccent => AppColors.onGold;

  /// Hairline in the ink colour at [opacity] (design uses .06 – .3).
  Color line([double opacity = 0.1]) => ink.withValues(alpha: opacity);

  /// The ground at [opacity] — for gradients that dissolve into the page.
  Color ground(double opacity) => background.withValues(alpha: opacity);

  Color accentAlpha(double opacity) => accent.withValues(alpha: opacity);

  static const dark = AppPalette(
    background: AppColors.night,
    surface: AppColors.umber,
    surfaceAlt: AppColors.umberDeep,
    deep: AppColors.vault,
    ink: AppColors.ivory,
    muted: AppColors.sand,
    accent: AppColors.gold,
    inverse: AppColors.ivory,
    onInverse: AppColors.night,
    inverseLink: AppColors.goldDeep,
    toggleOff: AppColors.umberMuted,
    knob: AppColors.ivory,
    danger: AppColors.rust,
    scrim: AppColors.scrimDark,
    glass: Color(0x73151515),
    shadow: Color(0x80000000),
    navPill: AppColors.umberLift,
    navIcon: AppColors.umberDeep,
    navLamp: AppColors.ivory,
  );

  static const light = AppPalette(
    background: AppColors.paper,
    surface: AppColors.linen,
    surfaceAlt: AppColors.linenSoft,
    deep: AppColors.parchment,
    ink: AppColors.charcoal,
    muted: AppColors.stone,
    accent: AppColors.brass,
    inverse: AppColors.charcoal,
    onInverse: AppColors.paper,
    inverseLink: AppColors.brassSoft,
    toggleOff: AppColors.linenMuted,
    knob: AppColors.white,
    danger: AppColors.rustLight,
    scrim: AppColors.scrimLight,
    glass: Color(0x99F7F3EC),
    shadow: Color(0x2E3A2C1A),
    navPill: AppColors.stone,
    navIcon: AppColors.umberMuted,
    navLamp: AppColors.white,
  );

  @override
  AppPalette copyWith({Color? background, Color? ink, Color? accent}) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface,
      surfaceAlt: surfaceAlt,
      deep: deep,
      ink: ink ?? this.ink,
      muted: muted,
      accent: accent ?? this.accent,
      inverse: inverse,
      onInverse: onInverse,
      inverseLink: inverseLink,
      toggleOff: toggleOff,
      knob: knob,
      danger: danger,
      scrim: scrim,
      glass: glass,
      shadow: shadow,
      navPill: navPill,
      navIcon: navIcon,
      navLamp: navLamp,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      deep: l(deep, other.deep),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      accent: l(accent, other.accent),
      inverse: l(inverse, other.inverse),
      onInverse: l(onInverse, other.onInverse),
      inverseLink: l(inverseLink, other.inverseLink),
      toggleOff: l(toggleOff, other.toggleOff),
      knob: l(knob, other.knob),
      danger: l(danger, other.danger),
      scrim: l(scrim, other.scrim),
      glass: l(glass, other.glass),
      shadow: l(shadow, other.shadow),
      navPill: l(navPill, other.navPill),
      navIcon: l(navIcon, other.navIcon),
      navLamp: l(navLamp, other.navLamp),
    );
  }
}
