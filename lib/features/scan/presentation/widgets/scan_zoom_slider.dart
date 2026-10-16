import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/tappable.dart';

/// Camera zoom as four round buttons — 1, 2, 3, 4 — the chosen one filled.
class ScanZoomControl extends StatelessWidget {
  const ScanZoomControl({
    super.key,
    required this.zoom,
    required this.onZoomChanged,
  });

  final double zoom;
  final ValueChanged<double> onZoomChanged;

  static const levels = [1.0, 2.0, 3.0, 4.0];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // The level nearest the current zoom is the selected one.
    var selected = 0;
    for (var i = 1; i < levels.length; i++) {
      if ((levels[i] - zoom).abs() < (levels[selected] - zoom).abs()) {
        selected = i;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < levels.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Tappable(
            onTap: () {
              if (i == selected) return;
              Haptics.play(HapticKind.selection);
              onZoomChanged(levels[i]);
            },
            semanticLabel: 'Zoom ${levels[i].round()}x',
            pressedScale: .9,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: Curves.easeOutCubic,
              width: i == selected ? 46 : 40,
              height: i == selected ? 46 : 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == selected ? p.accent : p.glass,
                border: Border.all(
                  color: i == selected ? p.accent : p.line(.3),
                  width: 1.2,
                ),
                boxShadow: i == selected
                    ? [
                        BoxShadow(
                          color: p.accent.withValues(alpha: .35),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '${levels[i].round()}',
                style:
                    AppTypography.sans(
                      i == selected ? 16 : 14,
                      weight: FontWeight.w700,
                    ).copyWith(
                      color: i == selected ? const Color(0xFF151515) : p.ink,
                      decoration: TextDecoration.none,
                    ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
