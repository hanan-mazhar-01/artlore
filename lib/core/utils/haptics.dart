import 'package:flutter/services.dart';

enum HapticKind { none, selection, light, medium, success }

/// Subtle, iOS-style haptic accents.
abstract final class Haptics {
  static void play(HapticKind kind) {
    switch (kind) {
      case HapticKind.none:
        return;
      case HapticKind.selection:
        HapticFeedback.selectionClick();
      case HapticKind.light:
        HapticFeedback.lightImpact();
      case HapticKind.medium:
        HapticFeedback.mediumImpact();
      case HapticKind.success:
        HapticFeedback.heavyImpact();
    }
  }
}
