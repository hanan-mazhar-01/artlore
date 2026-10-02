import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/media/focal.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/ambient_motion.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';

/// The front door of the app: a fragment of a painting seen through a gold
/// viewfinder, with a slow scanning line and a breathing glow. The whole
/// card opens the scanner.
class ScanArtworkCard extends StatefulWidget {
  const ScanArtworkCard({
    super.key,
    required this.artwork,
    required this.onTap,
  });

  /// The painting glimpsed in the background.
  final ArtImageSource artwork;
  final VoidCallback onTap;

  @override
  State<ScanArtworkCard> createState() => _ScanArtworkCardState();
}

class _ScanArtworkCardState extends State<ScanArtworkCard>
    with SingleTickerProviderStateMixin, LoopingTicker {
  @override
  Duration get loopDuration => const Duration(milliseconds: 3200);
  @override
  bool get loopReverse => true;

  static final _shape = AppRadius.css(6, 96, 6, 6);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = ClipRRect(
      borderRadius: _shape,
      child: SizedBox(
        height: 360,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ArtImage(
              widget.artwork,
              alignment: focal(.78, .3),
              decodeScale: 1.2,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [p.ground(.97), p.ground(.78), p.ground(.12)],
                  stops: const [0, .48, 1],
                ),
              ),
            ),
            // Kept inside the 96pt corner curve and clear of the copy.
            const Positioned(
              right: 40,
              top: 44,
              width: 104,
              height: 108,
              child: _Viewfinder(),
            ),
            Positioned(left: 24, right: 24, bottom: 24, child: _ScanCopy()),
          ],
        ),
      ),
    );
    return Tappable(
      onTap: widget.onTap,
      semanticLabel: 'Scan an artwork',
      haptic: HapticKind.light,
      pressedScale: .985,
      child: AnimatedBuilder(
        animation: loop,
        child: RepaintBoundary(child: content),
        builder: (context, child) {
          final g = Curves.easeInOut.transform(loop.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _shape,
              border: Border.all(color: p.accentAlpha(.22 + .14 * g)),
              boxShadow: [
                BoxShadow(
                  color: p.accentAlpha(.08 + .1 * g),
                  blurRadius: 26 + 14 * g,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Gold corner brackets with the scanning line running inside them.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Stack(
      fit: StackFit.expand,
      children: [
        CornerBrackets(color: p.accent, size: 24, stroke: 1.5, radius: 8),
        const Padding(
          padding: EdgeInsets.all(6),
          child: SweepLine(period: Duration(milliseconds: 2600)),
        ),
      ],
    );
  }
}

class _ScanCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const GoldLabel('Point · Scan · Discover', tracking: .24),
        const SizedBox(height: 10),
        EditorialHeading(
          lead: 'Discover',
          emphasis: 'a story.',
          breakLine: false,
          style: AppTypography.serif(36, weight: FontWeight.w500, height: 1),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Text(
            'Point your camera at any artwork and uncover the story '
            'behind it.',
            style: AppTypography.sans(13, height: 1.5).copyWith(color: p.muted),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: p.accent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ArtIcon(ArtIcons.scan, size: 18, color: p.onAccent),
              const SizedBox(width: 10),
              Text(
                'Scan Artwork',
                style: AppTypography.sans(
                  14,
                  weight: FontWeight.w700,
                ).copyWith(color: p.onAccent),
              ),
              const SizedBox(width: 10),
              ArtIcon(
                ArtIcons.arrowRight,
                size: 16,
                color: p.onAccent,
                strokeWidth: 1.8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
