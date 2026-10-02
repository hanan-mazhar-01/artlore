import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../icons/art_icons.dart';

/// One destination in the floating navigation.
///
/// Give either a [branch] (a tab of the shell, which keeps its own stack)
/// or a [route] (pushed full-screen over the tabs, e.g. the scanner).
@immutable
class ArtNavItem {
  const ArtNavItem.tab({
    required this.icon,
    required this.label,
    required int this.branch,
  }) : route = null;

  const ArtNavItem.action({
    required this.icon,
    required this.label,
    required String this.route,
  }) : branch = null;

  final ArtIconData icon;

  /// Spoken by screen readers; never drawn (the design has no labels).
  final String label;
  final int? branch;
  final String? route;
}

/// Proportions measured from the reference (a 540 × 104 pill), expressed
/// against the pill height so the bar scales cleanly on every phone.
@immutable
class FloatingNavMetrics {
  const FloatingNavMetrics._({
    required this.width,
    required this.height,
    required this.count,
  });

  /// Sizes the pill for a screen [screenWidth] wide.
  factory FloatingNavMetrics.forScreen(double screenWidth, int count) {
    final width = math.min(
      screenWidth - 48,
      (screenWidth * .78).clamp(272.0, 340.0),
    );
    final height = (width / 5.2).clamp(52.0, 64.0);
    return FloatingNavMetrics._(width: width, height: height, count: count);
  }

  final double width;
  final double height;
  final int count;

  double get padding => height * .4;
  double get slot => (width - padding * 2) / count;
  double get iconSize => height * .42;

  /// The lamp bar on the pill's top edge.
  double get barWidth => slot * .86;
  double get barHeight => height * .115;

  /// How far the light falls into the pill.
  double get coneHeight => height * .85;

  /// Horizontal centre of slot position [pos] (fractional while moving).
  double centerOf(double pos) => padding + slot * (pos + .5);

  @override
  bool operator ==(Object other) =>
      other is FloatingNavMetrics &&
      other.width == width &&
      other.height == height &&
      other.count == count;

  @override
  int get hashCode => Object.hash(width, height, count);
}
