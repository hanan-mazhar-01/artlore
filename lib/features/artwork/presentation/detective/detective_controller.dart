import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/detective_case.dart';

final detectiveCasesProvider = FutureProvider.autoDispose<List<DetectiveCase>>(
  (ref) => ref.watch(detectiveRepositoryProvider).fetchCases(),
);

/// A missed tap, kept briefly to draw its ripple.
@immutable
class MissTap {
  const MissTap(this.id, this.position);

  final int id;
  final Offset position;
}

@immutable
class DetectiveState {
  const DetectiveState({
    this.caseIndex = 0,
    this.misses = 0,
    this.taps = const [],
    this.hint = false,
    this.found = false,
  });

  final int caseIndex;
  final int misses;
  final List<MissTap> taps;
  final bool hint;
  final bool found;
}

final detectiveControllerProvider =
    NotifierProvider.autoDispose<DetectiveController, DetectiveState>(
      DetectiveController.new,
    );

class DetectiveController extends Notifier<DetectiveState> {
  int _tapIds = 0;

  @override
  DetectiveState build() => const DetectiveState();

  /// Judges a tap at [tap] inside a [box] showing [c]'s artwork with
  /// `BoxFit.cover`. Returns true when the detail is found.
  bool tap(DetectiveCase c, Offset tap, Size box, double imageAspect) {
    if (state.found) return true;
    final target = targetIn(c, box, imageAspect);
    if ((tap - target).distance < box.height * .15) {
      state = DetectiveState(caseIndex: state.caseIndex, found: true);
      return true;
    }
    final taps = [...state.taps, MissTap(_tapIds++, tap)];
    state = DetectiveState(
      caseIndex: state.caseIndex,
      misses: state.misses + 1,
      taps: taps.sublist(math.max(0, taps.length - 4)),
      hint: state.hint,
    );
    return false;
  }

  void showHint() => state = DetectiveState(
    caseIndex: state.caseIndex,
    misses: state.misses,
    taps: state.taps,
    hint: true,
  );

  void nextCase(int caseCount) =>
      state = DetectiveState(caseIndex: (state.caseIndex + 1) % caseCount);

  /// Where the case's target sits inside a cover-fitted box.
  static Offset targetIn(DetectiveCase c, Size box, double aspect) {
    final w = math.max(box.width, box.height * aspect);
    final h = w / aspect;
    final dx = (box.width - w) / 2, dy = (box.height - h) / 2;
    return Offset(dx + c.x * w, dy + c.y * h);
  }
}
