import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../domain/artwork.dart';

/// "— IDENTIFIED", title, artist and a "year · movement · city" line.
/// The museum, dimensions and medium live in [InfoChipsRow] instead.
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
        GoldLabel(
          kicker,
          size: 11,
          tracking: .24,
          weight: FontWeight.w600,
          leadingRule: true,
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            artwork.title,
            style: AppTypography.serif(
              36,
              weight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          artwork.artist,
          style: AppTypography.sans(15, weight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          '${artwork.year} · ${artwork.movement} · ${artwork.city}',
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
      ],
    );
  }
}
