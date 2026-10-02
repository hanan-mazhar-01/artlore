import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

/// Builds the Material themes from [AppPalette]. Material is only the host —
/// every ArtLore surface is drawn with custom components.
abstract final class AppTheme {
  static final ThemeData darkTheme = _build(AppPalette.dark, Brightness.dark);
  static final ThemeData lightTheme = _build(
    AppPalette.light,
    Brightness.light,
  );

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: p.danger,
      onError: p.onInverse,
      surface: p.background,
      onSurface: p.ink,
    );
    final base = AppTypography.sans(15).copyWith(color: p.ink);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      fontFamily: AppTypography.sansFamily,
      textTheme: TextTheme(
        bodyLarge: base,
        bodyMedium: base,
        bodySmall: base.copyWith(fontSize: 12),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accentAlpha(.3),
        selectionHandleColor: p.accent,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
      ),
      extensions: [p],
    );
  }
}
