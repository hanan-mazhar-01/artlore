import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/art_image.dart';
import '../../domain/artwork.dart';

/// Full-bleed artwork that dissolves into the page, drifting slower than
/// the scroll for a quiet parallax.
class ParallaxHero extends StatelessWidget {
  const ParallaxHero({
    super.key,
    required this.artwork,
    required this.scroll,
    this.alignment,
    this.fadeHeight = 160,
    this.fadeColors,
  });

  final Artwork artwork;
  final ScrollController scroll;
  final Alignment? alignment;
  final double fadeHeight;

  /// Override the dissolve gradient (top → bottom).
  final List<Color>? fadeColors;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final image = RepaintBoundary(
      child: ArtImage(
        artwork.image,
        alignment: alignment ?? artwork.heroFocus,
        semanticLabel: artwork.semanticLabel,
        decodeScale: 1.1,
      ),
    );
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: scroll,
            child: image,
            builder: (context, child) {
              final offset = scroll.hasClients ? scroll.offset : 0.0;
              return Transform.translate(
                offset: Offset(0, offset > 0 ? offset * .35 : 0),
                child: Transform.scale(
                  scale: offset < 0 ? 1 - offset / 600 : 1,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: fadeHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: fadeColors ?? [p.ground(0), p.background],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
