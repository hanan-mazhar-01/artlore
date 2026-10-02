import 'package:flutter/painting.dart';

/// CSS `object-position: x% y%` (as fractions) → [Alignment].
Alignment focal(double x, double y) => Alignment(x * 2 - 1, y * 2 - 1);
