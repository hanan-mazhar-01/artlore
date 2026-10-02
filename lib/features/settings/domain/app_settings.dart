import 'package:flutter/material.dart';

/// Every preference the visitor can change. Immutable; persisted locally.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.voice = 'The Curator',
    this.language = 'English',
    this.narrationLength = 1,
    this.saveEveryScan = true,
    this.showMarkers = true,
    this.reduceMotion = false,
    this.offlinePacks = false,
    this.dailyPainting = true,
    this.onboardingComplete = false,
  });

  /// ArtLore is a midnight gallery first — dark by default.
  final ThemeMode themeMode;
  final String voice;
  final String language;

  /// Index into the narration modes (Quick / Story / Deep Dive).
  final int narrationLength;
  final bool saveEveryScan;
  final bool showMarkers;
  final bool reduceMotion;
  final bool offlinePacks;
  final bool dailyPainting;
  final bool onboardingComplete;

  static const voices = ['The Curator', 'The Poet', 'The Historian'];
  static const languages = ['English', 'Français', 'Español', 'Deutsch'];

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? voice,
    String? language,
    int? narrationLength,
    bool? saveEveryScan,
    bool? showMarkers,
    bool? reduceMotion,
    bool? offlinePacks,
    bool? dailyPainting,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      voice: voice ?? this.voice,
      language: language ?? this.language,
      narrationLength: narrationLength ?? this.narrationLength,
      saveEveryScan: saveEveryScan ?? this.saveEveryScan,
      showMarkers: showMarkers ?? this.showMarkers,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      offlinePacks: offlinePacks ?? this.offlinePacks,
      dailyPainting: dailyPainting ?? this.dailyPainting,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

/// Local persistence for [AppSettings]. Reads are synchronous so the very
/// first frame already has the right theme.
abstract interface class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
