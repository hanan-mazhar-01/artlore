import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// [SettingsRepository] on top of SharedPreferences.
class PrefsSettingsRepository implements SettingsRepository {
  const PrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _p = 'artlore.settings.';

  @override
  AppSettings load() {
    const d = AppSettings();
    final theme = _prefs.getString('${_p}theme');
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == theme,
        orElse: () => d.themeMode,
      ),
      voice: _prefs.getString('${_p}voice') ?? d.voice,
      language: _prefs.getString('${_p}language') ?? d.language,
      narrationLength: _prefs.getInt('${_p}length') ?? d.narrationLength,
      saveEveryScan: _prefs.getBool('${_p}autosave') ?? d.saveEveryScan,
      showMarkers: _prefs.getBool('${_p}markers') ?? d.showMarkers,
      reduceMotion: _prefs.getBool('${_p}motion') ?? d.reduceMotion,
      offlinePacks: _prefs.getBool('${_p}offline') ?? d.offlinePacks,
      dailyPainting: _prefs.getBool('${_p}daily') ?? d.dailyPainting,
      onboardingComplete: _prefs.getBool('${_p}onboarded') ?? false,
    );
  }

  @override
  Future<void> save(AppSettings s) async {
    await Future.wait([
      _prefs.setString('${_p}theme', s.themeMode.name),
      _prefs.setString('${_p}voice', s.voice),
      _prefs.setString('${_p}language', s.language),
      _prefs.setInt('${_p}length', s.narrationLength),
      _prefs.setBool('${_p}autosave', s.saveEveryScan),
      _prefs.setBool('${_p}markers', s.showMarkers),
      _prefs.setBool('${_p}motion', s.reduceMotion),
      _prefs.setBool('${_p}offline', s.offlinePacks),
      _prefs.setBool('${_p}daily', s.dailyPainting),
      _prefs.setBool('${_p}onboarded', s.onboardingComplete),
    ]);
  }
}
