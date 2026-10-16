import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_toast.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import '../../domain/collection_models.dart';
import '../collection_controller.dart';
import '../collection_views.dart';
import 'custom_gallery_cards.dart';

/// Shows user-curated custom galleries with a strict maximum limit of 2.
class CustomGalleriesView extends ConsumerStatefulWidget {
  const CustomGalleriesView({super.key, required this.startDelay});

  final Duration startDelay;

  @override
  ConsumerState<CustomGalleriesView> createState() =>
      _CustomGalleriesViewState();
}

class _CustomGalleriesViewState extends ConsumerState<CustomGalleriesView> {
  String? _selectedGalleryId;

  void _createGalleryDialog(int currentCount) {
    if (currentCount >= maxCustomGalleries) {
      ArtToast.show(
        context,
        'Custom gallery limit reached (max $maxCustomGalleries)',
      );
      return;
    }
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final p = dialogCtx.palette;
        return AlertDialog(
          backgroundColor: p.surface,
          title: Text(
            'New Gallery',
            style: AppTypography.serif(24, weight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You can create up to $maxCustomGalleries custom galleries ($currentCount/$maxCustomGalleries used).',
                style: AppTypography.caption.copyWith(color: p.muted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.sans(15),
                decoration: InputDecoration(
                  hintText: 'e.g. Night Romantic, Renaissance',
                  hintStyle: AppTypography.sans(14).copyWith(color: p.muted),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: p.accent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Cancel', style: TextStyle(color: p.muted)),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogCtx).pop();
                  final g = await ref
                      .read(collectionProvider.notifier)
                      .createGallery(name);
                  if (!mounted) return;
                  setState(() => _selectedGalleryId = g.id);
                  ArtToast.show(context, 'Created "${g.name}"');
                }
              },
              child: Text('Create', style: TextStyle(color: p.accent)),
            ),
          ],
        );
      },
    );
  }

  void _deleteGallery(Gallery g) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogCtx.palette.surface,
        title: Text('Delete "${g.name}"?'),
        content: const Text(
          'Artworks in this gallery will be unassigned. You can then create a new gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(collectionProvider.notifier).deleteGallery(g.id);
              if (!mounted) return;
              setState(() => _selectedGalleryId = null);
              ArtToast.show(context, 'Deleted "${g.name}"');
            },
            child: Text(
              'Delete',
              style: TextStyle(color: dialogCtx.palette.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final snapshot = ref.watch(collectionProvider).value;
    if (snapshot == null) return const SizedBox.shrink();

    final customGalleries = snapshot.galleries
        .where((g) => g.id != 'favorites')
        .toList();

    if (_selectedGalleryId != null) {
      final gallery = snapshot.galleries.firstWhere(
        (g) => g.id == _selectedGalleryId,
        orElse: () => snapshot.galleries.first,
      );
      final worksAsync = ref.watch(galleryArtworksProvider(gallery.id));
      final works = worksAsync.value ?? const <Artwork>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tappable(
                  onTap: () => setState(() => _selectedGalleryId = null),
                  child: Row(
                    children: [
                      ArtIcon(ArtIcons.chevronLeft, size: 16, color: p.accent),
                      const SizedBox(width: 4),
                      Text(
                        'All Galleries',
                        style: AppTypography.sans(
                          14,
                          weight: FontWeight.w600,
                        ).copyWith(color: p.accent),
                      ),
                    ],
                  ),
                ),
                Tappable(
                  onTap: () => _deleteGallery(gallery),
                  child: ArtIcon(ArtIcons.close, size: 18, color: p.muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gallery.name, style: AppTypography.serif(28)),
                const SizedBox(height: 2),
                Text(
                  '${works.length} works',
                  style: AppTypography.caption.copyWith(color: p.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (works.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Center(
                child: Text(
                  'No artworks hung in this gallery yet.\nSave artworks here from the scan result or details screen.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: p.muted),
                ),
              ),
            )
          else
            GalleryArtworksBoxGrid(artworks: works),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom Galleries (${customGalleries.length}/$maxCustomGalleries)',
                style: AppTypography.sans(
                  13,
                  weight: FontWeight.w600,
                ).copyWith(color: p.muted),
              ),
              if (customGalleries.length < maxCustomGalleries)
                TextAction(
                  label: '+ New Gallery',
                  color: p.accent,
                  fontSize: 13,
                  onTap: () => _createGalleryDialog(customGalleries.length),
                )
              else
                Text(
                  'Max reached',
                  style: AppTypography.caption.copyWith(color: p.muted),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final g in customGalleries) ...[
            GalleryCard(
              gallery: g,
              count: snapshot.countIn(g.id),
              onTap: () => setState(() => _selectedGalleryId = g.id),
              onDelete: () => _deleteGallery(g),
            ),
            const SizedBox(height: 12),
          ],
          if (customGalleries.length < maxCustomGalleries)
            CreateGalleryCard(
              onTap: () => _createGalleryDialog(customGalleries.length),
            ),
        ],
      ),
    );
  }
}
