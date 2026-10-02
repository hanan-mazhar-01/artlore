import 'package:flutter/painting.dart';

/// CSS-style `brightness()` / `saturate()` as colour matrices.
abstract final class ColorFilters {
  /// Combined `saturate(s) brightness(b)`.
  static ColorFilter grade({double saturation = 1, double brightness = 1}) {
    const r = .2126, g = .7152, b = .0722;
    final s = saturation;
    final m = <double>[
      (r + (1 - r) * s) * brightness, (g - g * s) * brightness,
      (b - b * s) * brightness, 0, 0, //
      (r - r * s) * brightness, (g + (1 - g) * s) * brightness,
      (b - b * s) * brightness, 0, 0, //
      (r - r * s) * brightness, (g - g * s) * brightness,
      (b + (1 - b) * s) * brightness, 0, 0, //
      0, 0, 0, 1, 0,
    ];
    return ColorFilter.matrix(m);
  }
}
