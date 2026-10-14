import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';

/// The light-mode colour scheme of Home and Search, in one place so a new
/// scheme is a single edit. (Current: warm cream with an espresso banner.)
abstract final class HomeLight {
  static const ground = Color(0xFFF6F0E6); // page, warm cream
  static const surface = Color(0xFFEFE8DB); // search field, photos card
  static const peach = Color(0xFFEAE1D2); // collection card, tiles
  static const line = Color(0xFFE0D6C5); // hairlines
  static const ink = Color(0xFF2B2420); // text, espresso
  static const muted = Color(0xFF857A6D); // secondary text
  static const strong = Color(0xFF2D2621); // filter button, chips, scan button
  static const accent = Color(0xFFA9843A); // gold-ochre on the page
  static const bannerBg = Color(0xFF2D2621);
  static const bannerBorder = Color(0xFF3A322B);
  static const bannerText = Color(0xFFF3EBDD); // cream on the banner
  static const bannerAccent = Color(0xFFC9A45D); // label, "Story", brackets
  static const button = Color(0xFFE8DCC8); // "Scan a Painting" pill
  static const mote = Color(0xFFE8C98A);
}

/// The dark-mode scheme of Home and Search. (Current: espresso with a rich
/// brown banner, amber accents and cream buttons.)
abstract final class HomeDark {
  static const ground = Color(0xFF231710); // page
  static const surface = Color(0xFF2E1F16); // search field, cards
  static const tile = Color(0xFF3A281C); // placeholders, icon tiles
  static const line = Color(0xFF4A3426); // hairlines
  static const ink = Color(0xFFF5E9D8); // text, cream
  static const muted = Color(0xFFB89F86); // secondary text
  static const cream = Color(0xFFF3E4CF); // buttons, chips
  static const espresso = Color(0xFF2B1810); // ink on cream
  static const amber = Color(0xFFE9A84C); // "Story", labels, brackets
  static const bannerBg = Color(0xFF583318);
  static const bannerBorder = Color(0xFF6E4527);
  static const mote = Color(0xFFF0C27A);
}

/// Colours of the redesigned Home, resolved for the current theme. Dark keeps
/// the design's dark card and gold; light reads from [HomeLight].
class HomeStyle {
  const HomeStyle._(this.dark);

  factory HomeStyle.of(BuildContext context) => HomeStyle._(context.isDark);

  final bool dark;

  /// Page ground.
  Color get ground => dark ? HomeDark.ground : HomeLight.ground;

  /// Raised surface (search field, photo card, list rows).
  Color get surface => dark ? HomeDark.surface : HomeLight.surface;

  /// Hairlines and borders.
  Color get line => dark ? HomeDark.line : HomeLight.line;

  Color get ink => dark ? HomeDark.ink : HomeLight.ink;
  Color get muted => dark ? HomeDark.muted : HomeLight.muted;

  /// The strong card / button colour: umber in dark mode, amber in light.
  Color get deep => dark ? HomeDark.cream : HomeLight.strong;

  /// Text and icons on [deep].
  Color get onDeep => dark ? HomeDark.espresso : HomeLight.bannerText;

  /// Accent for icons sitting on [deep]: gold in dark, espresso in light.
  Color get onDeepAccent => dark ? HomeDark.espresso : HomeLight.bannerText;

  /// A softer card colour: dark umber in dark mode, peach in light.
  Color get card => dark ? HomeDark.surface : HomeLight.peach;

  /// Text laid over photographs — always light, whatever the theme.
  Color get onImage => const Color(0xFFF7F2EC);

  Color get gold => dark ? HomeDark.amber : HomeLight.accent;
  Color get goldLight => const Color(0xFFD9BC80);

  /// Accent that reads on the page: gold in dark, burnt orange in light.
  Color get goldDeep => dark ? HomeDark.amber : HomeLight.accent;

  /// Pale tile behind icons / badges.
  Color get goldTint => dark ? const Color(0x29E9A84C) : HomeLight.peach;

  /// Placeholder tile behind images.
  Color get tile => dark ? HomeDark.tile : HomeLight.peach;

  /// Shadow colour.
  Color shadow(double a) =>
      (dark ? const Color(0xFF000000) : HomeLight.ink).withValues(alpha: a);

  // — The hero banner. —

  Color get bannerBg => dark ? HomeDark.bannerBg : HomeLight.bannerBg;
  Color get bannerBorder =>
      dark ? HomeDark.bannerBorder : HomeLight.bannerBorder;
  Color get bannerText => dark ? HomeDark.ink : HomeLight.bannerText;
  Color get bannerAccent => dark ? HomeDark.amber : HomeLight.bannerAccent;
  Color get bannerAccentSoft => dark ? HomeDark.amber : HomeLight.bannerAccent;
  Color bannerBody(double a) =>
      (dark ? HomeDark.ink : HomeLight.bannerText).withValues(alpha: a);
  Color get bannerMote => dark ? HomeDark.mote : HomeLight.mote;
  double get bannerImageOpacity => .45;

  /// Optional banner gradient (none in the current schemes).
  Gradient? get bannerGradient => null;

  /// Soft glow behind the scan frame.
  Color get bannerGlow => const Color(0x33C9A45D);

  // The pill. Dark: cream with espresso ink and an espresso disc. Light: white
  // with ultramarine ink and an ultramarine disc holding a white arrow.
  Color get bannerBtnBg => dark ? HomeDark.cream : HomeLight.button;
  Color get bannerBtnInk => dark ? HomeDark.espresso : HomeLight.strong;
  Color get bannerBtnDisc => dark ? HomeDark.espresso : HomeLight.strong;
  Color get bannerBtnArrow => dark ? HomeDark.cream : HomeLight.button;
}
