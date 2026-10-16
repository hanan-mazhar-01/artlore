import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import '../../../artwork/presentation/widgets/artwork_card.dart';
import '../../domain/collection_models.dart';
import '../collection_views.dart';
import 'remove_artwork_sheet.dart';

/// Card representing a custom gallery with thumbnail cover and count.
class GalleryCard extends ConsumerWidget {
  const GalleryCard({
    super.key,
    required this.gallery,
    required this.count,
    required this.onTap,
    required this.onDelete,
  });

  final Gallery gallery;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final works =
        ref.watch(galleryArtworksProvider(gallery.id)).value ?? const [];
    final cover = works.isNotEmpty ? works.first.image : null;

    return Tappable(
      onTap: onTap,
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line(.12)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: cover != null
                    ? ArtImage(cover)
                    : Container(
                        color: p.ground(.1),
                        child: Icon(Icons.palette_outlined, color: p.muted),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gallery.name,
                    style: AppTypography.serif(18, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count ${count == 1 ? 'work' : 'works'}',
                    style: AppTypography.caption.copyWith(color: p.muted),
                  ),
                ],
              ),
            ),
            ArtIcon(ArtIcons.chevronRight, size: 16, color: p.muted),
          ],
        ),
      ),
    );
  }
}

/// Dotted/accent bordered card prompting user to create a new custom gallery.
class CreateGalleryCard extends StatelessWidget {
  const CreateGalleryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.accent.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: p.accent),
              const SizedBox(width: 8),
              Text(
                'Create Custom Gallery (up to $maxCustomGalleries)',
                style: AppTypography.sans(
                  14,
                  weight: FontWeight.w600,
                ).copyWith(color: p.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Staggered two-column artwork grid suitable for Box (RenderFlex) contexts.
class GalleryArtworksBoxGrid extends StatelessWidget {
  const GalleryArtworksBoxGrid({super.key, required this.artworks});

  final List<Artwork> artworks;

  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < artworks.length; i += 2) ...[
                  ArtworkCard(
                    artwork: artworks[i],
                    imageHeight: 220,
                    radius: AppRadius.round,
                    titleSize: 16,
                    titleGap: 8,
                    onTap: () => context.openArtwork(artworks[i].id),
                    onLongPress: () =>
                        showRemoveArtworkSheet(context, artworks[i]),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 40),
                for (int i = 1; i < artworks.length; i += 2) ...[
                  ArtworkCard(
                    artwork: artworks[i],
                    imageHeight: 220,
                    radius: AppRadius.round,
                    titleSize: 16,
                    titleGap: 8,
                    onTap: () => context.openArtwork(artworks[i].id),
                    onLongPress: () =>
                        showRemoveArtworkSheet(context, artworks[i]),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
