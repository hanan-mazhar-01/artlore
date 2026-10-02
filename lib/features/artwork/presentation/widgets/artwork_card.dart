import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork.dart';

/// An artwork with its caption beneath — the building block of every rail,
/// grid and collage. The silhouette ([radius]) and size come from the
/// layout, so neighbouring works never look identical.
class ArtworkCard extends StatelessWidget {
  const ArtworkCard({
    super.key,
    required this.artwork,
    required this.imageHeight,
    required this.radius,
    this.onTap,
    this.onLongPress,
    this.width,
    this.kicker,
    this.subtitle,
    this.titleSize = 17,
    this.titleGap = 10,
    this.subtitleSize = 11,
  });

  final Artwork artwork;
  final double imageHeight;
  final BorderRadius radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;

  /// Gold reason line above the title — "SAME PAINTER, SAME YEAR OF FIRE".
  final String? kicker;

  /// Defaults to the artist.
  final String? subtitle;
  final double titleSize;
  final double titleGap;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: ArtImage(
            artwork.image,
            radius: radius,
            alignment: artwork.heroFocus,
            semanticLabel: artwork.semanticLabel,
          ),
        ),
        SizedBox(height: kicker == null ? titleGap : 12),
        if (kicker != null) ...[
          GoldLabel(kicker!, tracking: .2, maxLines: 2),
          const SizedBox(height: 6),
        ],
        Text(
          artwork.title,
          style: AppTypography.serif(titleSize, height: 1.1),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          subtitle ?? artwork.artist,
          style: AppTypography.sans(subtitleSize).copyWith(color: p.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    return SizedBox(
      width: width,
      child: Tappable(
        onTap: onTap,
        onLongPress: onLongPress,
        semanticLabel: artwork.semanticLabel,
        child: card,
      ),
    );
  }
}
