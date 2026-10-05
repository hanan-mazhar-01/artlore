import 'package:flutter/widgets.dart';

import '../../extensions/context_x.dart';
import '../icons/art_icon.dart';
import '../icons/art_icons.dart';
import '../tappable.dart';

/// The scan action, standing apart from the tab pill as its own 3D gold
/// circle — camera-first, with tactile depth, beveled rim, specular reflections,
/// and an engraved icon.
class ScanFab extends StatelessWidget {
  const ScanFab({
    super.key,
    required this.diameter,
    required this.onTap,
  });

  /// Matches the pill's height, so the two sit flush in the same row.
  final double diameter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final iconSize = diameter * 0.40;

    return Tappable(
      onTap: onTap,
      semanticLabel: 'Scan an artwork',
      pressedScale: .92,
      child: Container(
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment(-0.25, -1.0),
            end: Alignment(0.25, 1.0),
            colors: [
              Color(0xFFFFF2B8), // Specular light highlight
              Color(0xFFE8C274), // Radiant gold
              Color(0xFFC89E4E), // Deep luxury gold
              Color(0xFFA67828), // Clean shaded bottom edge
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFFFFFDF0).withValues(alpha: .75),
            width: 1.5,
          ),
          boxShadow: [
            // Crisp neutral contact drop shadow (no brown halo)
            const BoxShadow(
              color: Color(0x55000000),
              offset: Offset(0, 5),
              blurRadius: 14,
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
            // Subtle warm gold ambient glow
            BoxShadow(
              color: p.accentAlpha(.25),
              blurRadius: 16,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Container(
          width: diameter * 0.75,
          height: diameter * 0.75,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF9E7324), // inset upper shadow
                Color(0xFFC9A250), // mid gold
                Color(0xFFDFC074), // bottom rim reflection
              ],
            ),
            border: Border.all(
              color: const Color(0x33000000),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D000000),
                offset: Offset(0, 1.5),
                blurRadius: 2.5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtly debossed / engraved specular highlight below icon
              Transform.translate(
                offset: const Offset(0, 1),
                child: ArtIcon(
                  ArtIcons.scanTab,
                  size: iconSize,
                  color: const Color(0x88FFF8DC),
                  strokeWidth: 1.9,
                ),
              ),
              // Core dark bronze stamped icon
              ArtIcon(
                ArtIcons.scanTab,
                size: iconSize,
                color: const Color(0xFF221605),
                strokeWidth: 1.9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
