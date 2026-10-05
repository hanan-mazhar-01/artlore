import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';

/// The 3D gold shutter button — elevated off the painting with tactile depth,
/// beveled rim, specular reflections, debossed icon, and a rhythmic tap animation
/// that zooms in (depresses) and zooms out (spring bounces) like a physical tap.
class ScanGlyph extends StatefulWidget {
  const ScanGlyph({
    super.key,
    required this.glow,
  });

  final Animation<double> glow;

  @override
  State<ScanGlyph> createState() => _ScanGlyphState();
}

class _ScanGlyphState extends State<ScanGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  static const _buttonSize = 64.0;
  static const _ringBox = 108.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _tapAnim.stop();
    } else {
      if (!_tapAnim.isAnimating) _tapAnim.repeat();
    }
  }

  @override
  void dispose() {
    _tapAnim.dispose();
    super.dispose();
  }

  _TapValues _calcTap(double u) {
    if (u < 0.30) {
      // Phase 1: Tap In / Press Down (0ms - 480ms)
      // Scale compresses down like a finger tapping it
      final t = Curves.easeInOutCubic.transform(u / 0.30);
      return _TapValues(
        scale: 1.0 - 0.10 * t,
        shadowBlur: 14.0 - 8.0 * t,
        shadowOffset: 6.0 - 3.5 * t,
        ringScale: 1.0,
        ringOpacity: 0.0,
      );
    } else if (u < 0.70) {
      // Phase 2: Pop Up / Zoom Out with Spring Bounce (480ms - 1120ms)
      // Bounces outward with easeOutBack overshoot and emits the gold radar wave
      final local = (u - 0.30) / 0.40;
      final t = Curves.easeOutBack.transform(local);
      final ringT = local.clamp(0.0, 1.0);
      return _TapValues(
        scale: 0.90 + 0.18 * t,
        shadowBlur: 6.0 + 12.0 * t,
        shadowOffset: 2.5 + 5.5 * t,
        ringScale: 1.0 + 0.65 * ringT,
        ringOpacity: ((1.0 - ringT).clamp(0.0, 1.0)) * 0.8,
      );
    } else {
      // Phase 3: Smooth Settle Back to Rest (1120ms - 1600ms)
      final t = Curves.easeInOut.transform((u - 0.70) / 0.30);
      return _TapValues(
        scale: 1.08 - 0.08 * t,
        shadowBlur: 18.0 - 4.0 * t,
        shadowOffset: 8.0 - 2.0 * t,
        ringScale: 1.65,
        ringOpacity: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _ringBox,
          height: _ringBox,
          child: AnimatedBuilder(
            animation: Listenable.merge([widget.glow, _tapAnim]),
            builder: (context, child) {
              final g = Curves.easeInOut.transform(widget.glow.value);
              final tap = _calcTap(_tapAnim.value);
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Synchronized radar ring expanding on pop-up
                  if (tap.ringOpacity > 0.01)
                    IgnorePointer(
                      child: Opacity(
                        opacity: tap.ringOpacity,
                        child: Transform.scale(
                          scale: tap.ringScale,
                          child: Container(
                            width: _buttonSize,
                            height: _buttonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: p.accent, width: 1.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Clean 3D tactile button zooming in and out like a tap
                  Transform.scale(
                    scale: tap.scale,
                    child: Container(
                      width: _buttonSize,
                      height: _buttonSize,
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
                          BoxShadow(
                            color: const Color(0x55000000),
                            offset: Offset(0, tap.shadowOffset),
                            blurRadius: tap.shadowBlur,
                            spreadRadius: 0,
                          ),
                          const BoxShadow(
                            color: Color(0x26000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                          // Subtle warm gold ambient breathing glow
                          BoxShadow(
                            color: p.accentAlpha(.25 + .20 * g),
                            blurRadius: 16 + 8 * g,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ],
              );
            },
            child: Container(
              width: _buttonSize - 16,
              height: _buttonSize - 16,
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
                    child: const ArtIcon(
                      ArtIcons.scan,
                      size: 24,
                      color: Color(0x88FFF8DC),
                      strokeWidth: 1.9,
                    ),
                  ),
                  // Core dark bronze stamped icon
                  const ArtIcon(
                    ArtIcons.scan,
                    size: 24,
                    color: Color(0xFF221605),
                    strokeWidth: 1.9,
                  ),
                ],
              ),
            ),
          ),
        ),
        Text(
          'Scan Artwork',
          style: AppTypography.sans(
            18,
            weight: FontWeight.w700,
          ).copyWith(color: AppColors.ivory),
        ),
        const SizedBox(height: 4),
        Text(
          'Point your camera at a painting',
          style: AppTypography.caption.copyWith(color: AppColors.sand),
        ),
      ],
    );
  }
}

class _TapValues {
  const _TapValues({
    required this.scale,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.ringScale,
    required this.ringOpacity,
  });

  final double scale;
  final double shadowBlur;
  final double shadowOffset;
  final double ringScale;
  final double ringOpacity;
}
