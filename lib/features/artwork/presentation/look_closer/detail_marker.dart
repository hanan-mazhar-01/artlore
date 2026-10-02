import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/tappable.dart';

/// A numbered pin on the canvas. Keeps a constant on-screen size while the
/// canvas zooms (it listens to [zoom] on its own, so only pins rebuild), and
/// breathes with a gold pulse until chosen.
class DetailMarker extends StatelessWidget {
  const DetailMarker({
    super.key,
    required this.number,
    required this.active,
    required this.zoom,
    required this.pulse,
    required this.onTap,
    required this.label,
  });

  final String number;
  final bool active;
  final ValueListenable<double> zoom;
  final Animation<double> pulse;
  final VoidCallback onTap;
  final String label;

  static const size = 34.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pin = Tappable(
      onTap: onTap,
      semanticLabel: 'Detail $number: $label',
      pressedScale: .92,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: AppMotion.medium,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? p.accent : p.glass,
              border: Border.all(color: active ? p.accent : p.line(.7)),
            ),
            child: Text(
              number,
              style: AppTypography.sans(
                11,
                weight: FontWeight.w700,
              ).copyWith(color: active ? p.onAccent : p.ink),
            ),
          ),
        ),
      ),
    );
    return ValueListenableBuilder<double>(
      valueListenable: zoom,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (!active)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: pulse,
                builder: (context, _) => Transform.scale(
                  scale: 1 + 1.2 * pulse.value,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: p.accentAlpha(.7 * (1 - pulse.value)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          pin,
        ],
      ),
      builder: (context, z, child) =>
          Transform.scale(scale: 1 / z, child: child),
    );
  }
}
