import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';

/// "Take a closer look" — one magazine feature closing the page. Quieter
/// than the scan card: it bleeds to the right edge with an arched corner.
class FeaturedArtworkSection extends StatelessWidget {
  const FeaturedArtworkSection({super.key, required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    void open() => context.push(AppRoutes.story(artwork.id));
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 48),
      child: Tappable(
        onTap: open,
        pressedScale: .99,
        semanticLabel: 'Take a closer look: ${artwork.semanticLabel}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 24, bottom: 16),
              child: SectionHeader(title: 'Take a closer look'),
            ),
            SizedBox(
              height: 250,
              child: ArtImage(
                artwork.image,
                radius: AppRadius.css(120, 0, 0, 6),
                alignment: artwork.heroFocus,
                shadow: AppShadows.card(p),
                semanticLabel: artwork.semanticLabel,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    style: AppTypography.serif(
                      26,
                      weight: FontWeight.w500,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    artwork.byline,
                    style: AppTypography.caption.copyWith(color: p.muted),
                  ),
                  const SizedBox(height: 6),
                  ArrowLink(label: 'Explore story', onTap: open),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
