import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../paywall/presentation/premium_controller.dart';

/// Viewfinder states before recognition starts.
enum ScanPhase {
  /// "Align the artwork" — the canvas is tilted and dim.
  ready,

  /// "Artwork detected" — the frame locks on and the gold sweep runs.
  detected,

  /// Shutter pressed; handing over to recognition.
  capturing,
}

enum CaptureOutcome { proceed, needsPremium, busy }

final scanControllerProvider =
    NotifierProvider.autoDispose<ScanController, ScanPhase>(ScanController.new);

class ScanController extends Notifier<ScanPhase> {
  static const detectAfter = Duration(milliseconds: 1600);
  static const captureHold = Duration(milliseconds: 500);

  @override
  ScanPhase build() {
    // Mock detection: a real camera pipeline would emit this from frames.
    final timer = Timer(detectAfter, () {
      if (state == ScanPhase.ready) state = ScanPhase.detected;
    });
    ref.onDispose(timer.cancel);
    return ScanPhase.ready;
  }

  /// Shutter. Resolves once the UI should move on to recognition.
  Future<CaptureOutcome> capture() async {
    if (state == ScanPhase.capturing) return CaptureOutcome.busy;
    final premium = await ref.read(premiumProvider.future);
    if (!ref.mounted) return CaptureOutcome.busy;
    if (!premium.canScan) return CaptureOutcome.needsPremium;
    state = ScanPhase.capturing;
    await Future<void>.delayed(captureHold);
    return ref.mounted ? CaptureOutcome.proceed : CaptureOutcome.busy;
  }
}
