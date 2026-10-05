import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../../core/widgets/tappable.dart';
import 'scan_glyph.dart';

/// The front door of the app: a framed painting behind a gold viewfinder,
/// with the 3D scan button at its heart. The whole card opens the scanner.
class ScanArtworkCard extends StatefulWidget {
  const ScanArtworkCard({
    super.key,
    required this.artwork,
    required this.onTap,
  });

  /// The painting shown inside the frame.
  final ArtImageSource artwork;
  final VoidCallback onTap;

  @override
  State<ScanArtworkCard> createState() => _ScanArtworkCardState();
}

class _ScanArtworkCardState extends State<ScanArtworkCard>
    with SingleTickerProviderStateMixin {
  /// Breathing glow on the button, in lockstep with the blinking corner.
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _glow.stop();
    } else {
      if (!_glow.isAnimating) _glow.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  static const _outerRadius = 24.0;
  static const _innerRadius = 18.0;
  static const _imageHeight = 230.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(_innerRadius - 3),
      child: SizedBox(
        height: _imageHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // A hair of blur so the button and copy read as sitting above
            // the painting rather than printed on it.
            Hero(
              tag: 'scan-viewfinder-hero',
              createRectTween: (begin, end) => AppMotion.rectTween(begin, end),
              flightShuttleBuilder: (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) {
                return AppMotion.heroShuttle(
                  animation: animation,
                  flightDirection: flightDirection,
                  fromHeroContext: fromHeroContext,
                  toHeroContext: toHeroContext,
                  startRadius: BorderRadius.circular(_innerRadius - 3),
                  endRadius: BorderRadius.zero,
                );
              },
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 1.4),
                child: ArtImage(
                  widget.artwork,
                  semanticLabel: 'Starry Night, sample scan',
                ),
              ),
            ),
            // A soft vignette keeps the button and copy legible on any
            // painting, in either theme.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: .9,
                  colors: [Color(0x59000000), Color(0x00000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: CornerBrackets(
                color: AppColors.ivory.withValues(alpha: .85),
                size: 26,
                stroke: 1.6,
                radius: 10,
                topLeftBlink: _glow,
              ),
            ),
            Center(
              child: ScanGlyph(glow: _glow),
            ),
          ],
        ),
      ),
    );
    return Tappable(
      onTap: widget.onTap,
      semanticLabel: 'Scan an artwork',
      haptic: HapticKind.light,
      pressedScale: .985,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(_outerRadius),
          boxShadow: AppShadows.card(p),
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: p.accentAlpha(.5)),
            borderRadius: BorderRadius.circular(_innerRadius),
          ),
          child: content,
        ),
      ),
    );
  }
}
