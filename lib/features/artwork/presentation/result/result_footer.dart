import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';

/// "Compare with Monet" — two overlapping discs in a half-pill.
class CompareEntry extends ConsumerWidget {
  const CompareEntry({
    super.key,
    required this.artwork,
    required this.comparison,
  });

  final Artwork artwork;
  final ArtworkComparison comparison;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final other = ref.watch(artworkProvider(comparison.otherId)).value;
    Widget disc(Artwork a) => Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: p.surface, width: 2),
      ),
      child: ClipOval(child: ArtImage(a.image)),
    );
    return Tappable(
      onTap: () => context.push(AppRoutes.compare(artwork.id)),
      semanticLabel: comparison.title,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: AppRadius.css(40, 6, 6, 40),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              height: 44,
              child: Stack(
                children: [
                  disc(artwork),
                  if (other != null) Positioned(left: 30, child: disc(other)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comparison.title,
                    style: AppTypography.sans(13, weight: FontWeight.w600),
                  ),
                  Text(
                    comparison.subtitle,
                    style: AppTypography.metadata.copyWith(color: p.muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                '×',
                style: AppTypography.sans(12).copyWith(color: p.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined call to scan again.
class ScanAnotherButton extends StatelessWidget {
  const ScanAnotherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: () => context.push(AppRoutes.scan),
      semanticLabel: 'Scan another artwork',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: p.accentAlpha(.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Scan another artwork',
                style: AppTypography.sans(14, weight: FontWeight.w600),
              ),
            ),
            ArtIcon(ArtIcons.scan, size: 20, color: p.accent, strokeWidth: 1.5),
          ],
        ),
      ),
    );
  }
}
