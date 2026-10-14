import 'package:flutter/widgets.dart';

import '../../extensions/context_x.dart';
import '../icons/art_icon.dart';
import '../icons/art_icons.dart';
import '../tappable.dart';

/// The scan action beside the tab pill, filled with the theme's gold accent
/// (the same gold as the "Scan from Photos" icon) with the pill's shadow.
class ScanFab extends StatelessWidget {
  const ScanFab({super.key, required this.diameter, required this.onTap});

  /// Matches the pill's height, so the two sit flush in the same row.
  final double diameter;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: 'Scan an artwork',
      pressedScale: .92,
      child: Container(
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Gold in dark mode; dark chocolate in light.
          color: context.isDark
              ? const Color(0xFFF3E4CF)
              : const Color(0xFF2D2621),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: p.shadow.a * .5),
              offset: Offset(diameter * .05, diameter * .2),
              blurRadius: diameter * .6,
            ),
          ],
        ),
        // The same camera mark, and dark ink, as the home banner's button.
        child: ArtIcon(
          ArtIcons.camera,
          size: diameter * 0.46,
          color: context.isDark
              ? const Color(0xFF2B1810)
              : const Color(0xFFF3EBDD),
          strokeWidth: 1.9,
        ),
      ),
    );
  }
}
