import 'package:flutter/widgets.dart';

/// The design's artwork "frames" — asymmetric radii that give each work its
/// own silhouette instead of identical rounded cards.
///
/// Radii follow CSS order: top-left, top-right, bottom-right, bottom-left.
abstract final class AppRadius {
  static BorderRadius css(double tl, double tr, double br, double bl) {
    return BorderRadius.only(
      topLeft: Radius.circular(tl),
      topRight: Radius.circular(tr),
      bottomRight: Radius.circular(br),
      bottomLeft: Radius.circular(bl),
    );
  }

  /// A gallery arch — `120px 120px 4px 4px`.
  static final arch = css(120, 120, 4, 4);

  /// A plain canvas — `4px`.
  static const soft = BorderRadius.all(Radius.circular(4));

  /// A leaf — `4px 56px 4px 56px`.
  static final leaf = css(4, 56, 4, 56);

  /// A soft tile — `26px`.
  static const round = BorderRadius.all(Radius.circular(26));

  /// A swept corner — `80px 4px 4px 4px`.
  static final sweep = css(80, 4, 4, 4);

  static const canvas = BorderRadius.all(Radius.circular(6));
}

/// Named artwork silhouettes, so data and layout specs can refer to them.
enum ArtShape {
  arch,
  soft,
  leaf,
  round,
  sweep;

  BorderRadius get radius => switch (this) {
    ArtShape.arch => AppRadius.arch,
    ArtShape.soft => AppRadius.soft,
    ArtShape.leaf => AppRadius.leaf,
    ArtShape.round => AppRadius.round,
    ArtShape.sweep => AppRadius.sweep,
  };
}
