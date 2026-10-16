import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../icons/art_icons.dart';

/// One tab of the floating pill — a branch of the shell, which keeps its
/// own navigation stack. The scan action lives beside the pill instead,
/// as its own circular button — see `ScanFab`.
@immutable
class ArtNavItem {
  const ArtNavItem({
    required this.icon,
    required this.label,
    required this.branch,
  });

  final ArtIconData icon;

  /// Spoken by screen readers; never drawn (the design has no labels).
  final String label;
  final int branch;
}

/// Proportions measured from the reference (a 540 × 104 pill), expressed
/// against the pill height so the bar scales cleanly on every phone.
@immutable
class FloatingNavMetrics {
  const FloatingNavMetrics._({
    required this.width,
    required this.height,
    required this.count,
    this.mock = false,
  });

  /// The nav as drawn in the HTML mock-up (`ui mock up/home-redesign.html`):
  /// a 340 × 62 pill whose last 78 is the scan button's end, so the tabs
  /// share the first 262. Everything scales down together on a narrow phone.
  /// [width] here is the tabs' part of the pill (the scan end is added by the
  /// dock).
  factory FloatingNavMetrics.mock(double screenWidth, int count) {
    final total = math.min(screenWidth - 48, 340.0);
    final k = (total / 340).clamp(.86, 1.0);
    return FloatingNavMetrics._(
      width: total - 78 * k,
      height: 62 * k,
      count: count,
      mock: true,
    );
  }

  /// Sizes the pill for a screen [screenWidth] wide, leaving the usual
  /// 24pt gutter on each side. Pass [reservedWidth] for anything sharing
  /// that row beside the pill (e.g. the separate scan button + its gap),
  /// so the two together still clear the edge rather than the pill alone.
  factory FloatingNavMetrics.forScreen(
    double screenWidth,
    int count, {
    double reservedWidth = 0,
  }) {
    final width = math.min(
      screenWidth - 48 - reservedWidth,
      (screenWidth * .78).clamp(272.0, 340.0),
    );
    final height = (width / 5.2).clamp(52.0, 64.0);
    return FloatingNavMetrics._(width: width, height: height, count: count);
  }

  final double width;
  final double height;
  final int count;

  /// Sized after the mock-up rather than the first reference.
  final bool mock;

  double get padding => mock ? height * .194 : height * .4;
  double get slot => (width - padding * 2) / count;
  double get iconSize => mock ? height * .387 : height * .42;

  /// The lamp bar on the pill's top edge.
  double get barWidth => mock ? slot * .78 : slot * .86;
  double get barHeight => mock ? height * .097 : height * .115;

  /// How far the light falls into the pill.
  double get coneHeight => mock ? height * .8 : height * .85;

  /// Horizontal centre of slot position [pos] (fractional while moving).
  double centerOf(double pos) => padding + slot * (pos + .5);

  @override
  bool operator ==(Object other) =>
      other is FloatingNavMetrics &&
      other.width == width &&
      other.height == height &&
      other.count == count &&
      other.mock == mock;

  @override
  int get hashCode => Object.hash(width, height, count, mock);
}
