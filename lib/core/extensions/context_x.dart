import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

extension ArtContext on BuildContext {
  /// The active ArtLore palette (dark or light).
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Distance from the top of the screen to the first row of content —
  /// the design's 62pt on a notched iPhone.
  double get topInset =>
      MediaQuery.paddingOf(this).top + AppSpacing.belowStatusBar;

  double get bottomInset => MediaQuery.paddingOf(this).bottom;

  Size get screenSize => MediaQuery.sizeOf(this);
}
