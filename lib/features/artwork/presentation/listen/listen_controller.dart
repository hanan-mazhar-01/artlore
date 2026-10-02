import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/settings_controller.dart';
import '../../domain/artwork_content.dart';

@immutable
class ListenState {
  const ListenState({
    required this.mode,
    required this.position,
    required this.playing,
  });

  final int mode;

  /// Seconds into the narration.
  final int position;
  final bool playing;

  ListenState copyWith({int? mode, int? position, bool? playing}) =>
      ListenState(
        mode: mode ?? this.mode,
        position: position ?? this.position,
        playing: playing ?? this.playing,
      );
}

/// Mock audio player — a ticking clock with the controls of a real one.
/// An audio-backed implementation keeps the same surface.
final listenControllerProvider = NotifierProvider.autoDispose
    .family<ListenController, ListenState, Narration>(ListenController.new);

class ListenController extends Notifier<ListenState> {
  ListenController(this.narration);

  final Narration narration;
  Timer? _clock;

  int get duration => narration.modes[state.mode].seconds;

  /// Index of the chapter playing at [s].
  static int chapterAt(Narration n, ListenState s) => math.min(
    n.chapters.length - 1,
    (s.position / n.modes[s.mode].seconds * n.chapters.length).floor(),
  );

  @override
  ListenState build() {
    ref.onDispose(() => _clock?.cancel());
    final preferred = ref.read(settingsProvider).narrationLength;
    final mode = preferred.clamp(0, narration.modes.length - 1);
    return ListenState(mode: mode, position: 37, playing: false);
  }

  void toggle() => state.playing ? _pause() : _play();

  void _play() {
    if (state.position >= duration) state = state.copyWith(position: 0);
    state = state.copyWith(playing: true);
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.position >= duration) {
        _pause();
      } else {
        state = state.copyWith(position: state.position + 1);
      }
    });
  }

  void _pause() {
    _clock?.cancel();
    _clock = null;
    state = state.copyWith(playing: false);
  }

  void seekFraction(double f) =>
      state = state.copyWith(position: (f.clamp(0, 1) * duration).round());

  void skip(int seconds) => state = state.copyWith(
    position: (state.position + seconds).clamp(0, duration),
  );

  void setMode(int mode) {
    final max = narration.modes[mode].seconds;
    state = state.copyWith(mode: mode, position: math.min(state.position, max));
  }
}
