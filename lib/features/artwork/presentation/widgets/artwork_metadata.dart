import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../domain/artwork.dart';

/// "— IDENTIFIED", title, artist and the museum label line.
class ArtworkMetadata extends StatelessWidget {
  const ArtworkMetadata({
    super.key,
    required this.artwork,
    this.kicker = 'Identified',
  });

  final Artwork artwork;
  final String kicker;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldLabel(kicker, tracking: .24, leadingRule: true),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            artwork.title,
            style: AppTypography.serif(
              44,
              weight: FontWeight.w500,
              height: .98,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          artwork.artist,
          style: AppTypography.sans(15, weight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          artwork.metadataLine,
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
        Text(
          artwork.movement,
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
      ],
    );
  }
}
