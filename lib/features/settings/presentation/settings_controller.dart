import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/app_settings.dart';

/// Visitor preferences. Synchronous state, persisted on every change.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Narrowed views so widgets rebuild only for what they use.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider.select((s) => s.themeMode)),
);
final reduceMotionProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.reduceMotion)),
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  void _update(AppSettings next) {
    state = next;
    ref.read(settingsRepositoryProvider).save(next);
  }

  void setThemeMode(ThemeMode mode) => _update(state.copyWith(themeMode: mode));

  void setNarrationLength(int index) =>
      _update(state.copyWith(narrationLength: index));

  void cycleNarrationLength() =>
      setNarrationLength((state.narrationLength + 1) % 3);

  void cycleVoice() =>
      _update(state.copyWith(voice: _next(AppSettings.voices, state.voice)));

  void cycleLanguage() => _update(
    state.copyWith(language: _next(AppSettings.languages, state.language)),
  );

  void toggleSaveEveryScan() =>
      _update(state.copyWith(saveEveryScan: !state.saveEveryScan));

  void toggleMarkers() =>
      _update(state.copyWith(showMarkers: !state.showMarkers));

  void toggleReduceMotion() =>
      _update(state.copyWith(reduceMotion: !state.reduceMotion));

  void toggleOfflinePacks() =>
      _update(state.copyWith(offlinePacks: !state.offlinePacks));

  void toggleDailyPainting() =>
      _update(state.copyWith(dailyPainting: !state.dailyPainting));

  void completeOnboarding() {
    if (!state.onboardingComplete) {
      _update(state.copyWith(onboardingComplete: true));
    }
  }

  /// Mock sign-out: return the visitor to the welcome door.
  void signOut() => _update(state.copyWith(onboardingComplete: false));

  static String _next(List<String> options, String current) {
    final i = options.indexOf(current);
    return options[(i + 1) % options.length];
  }
}
