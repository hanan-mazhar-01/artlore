import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../history/presentation/history_controller.dart';
import '../../../paywall/presentation/premium_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/recognition.dart';
import '../scan_controller.dart';

/// The four quiet beats of "Reading the artwork…".
const analysisSteps = [
  'Looking closely',
  'Identifying the artist',
  'Reading the composition',
  'Uncovering its story',
];

@immutable
class AnalysisState {
  const AnalysisState({
    this.step = 0,
    this.result,
    this.failed = false,
    this.errorDetail,
    this.unsupportedSubject,
  });

  /// Index of the step in progress.
  final int step;

  /// Set once identification and the reading ritual have both finished.
  final Identification? result;
  final bool failed;

  /// Technical reason recognition failed — shown in small print for
  /// diagnosis, e.g. "gemini-3.5-flash: HTTP 429 RESOURCE_EXHAUSTED".
  final String? errorDetail;

  /// Set instead of a generic failure when the photo clearly wasn't of an
  /// artwork at all — e.g. "a person" — so the UI can say so plainly.
  final String? unsupportedSubject;

  AnalysisState copyWith({
    int? step,
    Identification? result,
    bool? failed,
    String? errorDetail,
    String? unsupportedSubject,
  }) => AnalysisState(
    step: step ?? this.step,
    result: result ?? this.result,
    failed: failed ?? this.failed,
    errorDetail: errorDetail ?? this.errorDetail,
    unsupportedSubject: unsupportedSubject ?? this.unsupportedSubject,
  );
}

final analysisControllerProvider = NotifierProvider.autoDispose
    .family<AnalysisController, AnalysisState, String?>(AnalysisController.new);

/// Runs recognition while pacing the on-screen steps, so even an instant
/// answer still feels considered.
///
/// [photoId] is set when reading a library photo instead of the camera.
class AnalysisController extends Notifier<AnalysisState> {
  AnalysisController(this.photoId);

  final String? photoId;

  static const stepEvery = Duration(milliseconds: 1300);
  static const settle = Duration(milliseconds: 1100);

  @override
  AnalysisState build() {
    final ritual = Completer<void>();
    Timer? settling;
    final ticker = Timer.periodic(stepEvery, (t) {
      if (state.step >= analysisSteps.length - 1) {
        t.cancel();
        settling = Timer(settle, () {
          if (!ritual.isCompleted) ritual.complete();
        });
      } else {
        state = state.copyWith(step: state.step + 1);
      }
    });
    ref.onDispose(() {
      ticker.cancel();
      settling?.cancel();
    });
    _run(ritual.future);
    return const AnalysisState();
  }

  Future<void> _run(Future<void> ritual) async {
    try {
      final recognition = ref.read(recognitionRepositoryProvider);
      final bytes = ref.read(pendingFrameBytesProvider);
      final results = await Future.wait([
        recognition.identify(CapturedFrame(bytes: bytes, photoId: photoId)),
        ritual,
      ]);
      if (!ref.mounted) return;
      final id = results.first as Identification;
      await ref.read(premiumProvider.notifier).consumeScan();
      if (ref.read(settingsProvider).saveEveryScan) {
        await ref
            .read(historyProvider.notifier)
            .recordScan(artworkId: id.artworkId, where: id.where);
      }
      if (ref.mounted) state = state.copyWith(result: id);
    } on UnsupportedSubjectException catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          failed: true,
          unsupportedSubject: e.description?.isNotEmpty == true
              ? e.description
              : 'something else',
        );
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(failed: true, errorDetail: e.toString());
      }
    }
  }
}
