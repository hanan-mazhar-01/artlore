import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../paywall/presentation/premium_controller.dart';

/// Holds real camera or gallery image bytes across the scan->analysis transition.
class PendingFrameBytesNotifier extends Notifier<Uint8List?> {
  @override
  Uint8List? build() => null;

  @override
  set state(Uint8List? value) => super.state = value;
}

final pendingFrameBytesProvider =
    NotifierProvider<PendingFrameBytesNotifier, Uint8List?>(
  PendingFrameBytesNotifier.new,
);

/// Viewfinder states before recognition starts.
enum ScanPhase {
  /// "Align the artwork" — the canvas is tilted and dim.
  ready,

  /// "Artwork detected" — the frame locks on and the gold sweep runs.
  detected,

  /// Shutter pressed; handing over to recognition.
  capturing,
}

enum CaptureOutcome { proceed, needsAccount, needsPremium, busy }

final scanControllerProvider =
    NotifierProvider.autoDispose<ScanController, ScanPhase>(ScanController.new);

class ScanController extends Notifier<ScanPhase> {
  static const captureHold = Duration(milliseconds: 600);

  @override
  ScanPhase build() => ScanPhase.ready;

  /// Freezes the viewfinder immediately on shutter press, before the (slower)
  /// photo capture and crop work runs — so the UI responds the instant the
  /// visitor taps, instead of the live feed appearing to keep running until
  /// that work finishes.
  void beginCapturing() => state = ScanPhase.capturing;

  /// Reverts the freeze if the gate below sends the visitor elsewhere (e.g.
  /// the account wall or paywall), so returning to this screen shows the
  /// live preview again rather than a stale frozen frame.
  void resetToReady() {
    if (state == ScanPhase.capturing) state = ScanPhase.ready;
  }

  void resetToDetected() => resetToReady();

  /// Resolves once the UI should move on to recognition. Assumes
  /// [beginCapturing] was already called to freeze the viewfinder.
  Future<CaptureOutcome> capture() async {
    final premium = await ref.read(premiumProvider.future);
    if (!ref.mounted) return CaptureOutcome.busy;
    if (!premium.canScan) {
      return premium.requiresAccount
          ? CaptureOutcome.needsAccount
          : CaptureOutcome.needsPremium;
    }
    await Future<void>.delayed(captureHold);
    return ref.mounted ? CaptureOutcome.proceed : CaptureOutcome.busy;
  }
}
