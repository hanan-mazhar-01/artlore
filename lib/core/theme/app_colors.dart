import 'package:flutter/painting.dart';

/// Raw colour values taken from the ArtLore design.
///
/// Widgets never read these directly — they go through [AppPalette], which
/// maps them onto semantic roles for the dark and light themes.
abstract final class AppColors {
  // — Midnight gallery (dark, design source) —
  static const night = Color(0xFF151515);
  static const ivory = Color(0xFFF5EFE5);
  static const sand = Color(0xFFB8AEA0);
  static const umber = Color(0xFF282522);
  static const umberDeep = Color(0xFF1D1B19);
  static const gold = Color(0xFFC9A45C);
  static const goldDeep = Color(0xFF8A6A2C);
  static const vault = Color(0xFF0F0F0E);
  static const umberMuted = Color(0xFF3A3632);
  static const umberLift = Color(0xFF48423C);
  static const rust = Color(0xFFA8593F);
  static const scrimDark = Color(0x990A0A09);

  // — Daylight gallery (light) —
  static const paper = Color(0xFFF7F3EC);
  static const charcoal = Color(0xFF25221E);
  static const stone = Color(0xFF746D63);
  static const linen = Color(0xFFEEE8DE);
  static const linenSoft = Color(0xFFF2EDE4);
  static const brass = Color(0xFFB99455);
  static const brassSoft = Color(0xFFD8C19A);
  static const parchment = Color(0xFFEDE6DA);
  static const linenMuted = Color(0xFFD9D1C4);
  static const white = Color(0xFFFFFFFF);
  static const rustLight = Color(0xFF9A4B33);
  static const scrimLight = Color(0x8025221E);

  // — Camera viewfinder (always dark, like the iOS camera) —
  static const cameraBlack = Color(0xFF0A0A09);
  static const cameraWarm = Color(0xFF3A352F);
  static const cameraMid = Color(0xFF1D1A17);
  static const frameWood = Color(0xFF2A1F14);

  /// Ink used on top of gold surfaces in both themes.
  static const onGold = Color(0xFF151515);
}
