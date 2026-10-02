import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_sheet.dart';
import '../../../../core/widgets/art_toast.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../artwork/domain/artwork.dart';
import '../collection_controller.dart';
import 'gallery_picker.dart';

/// Opens "Hang it in a gallery" for [artwork].
Future<void> showSaveArtworkSheet(BuildContext context, Artwork artwork) {
  return showArtSheet<void>(context, child: SaveArtworkSheet(artwork: artwork));
}

class SaveArtworkSheet extends ConsumerStatefulWidget {
  const SaveArtworkSheet({super.key, required this.artwork});

  final Artwork artwork;

  @override
  ConsumerState<SaveArtworkSheet> createState() => _SaveArtworkSheetState();
}

class _SaveArtworkSheetState extends ConsumerState<SaveArtworkSheet> {
  String? _galleryId;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final snapshot = ref.watch(collectionProvider).value;
    if (snapshot == null) return const SizedBox(height: 240);
    final galleries = snapshot.galleries;
    final current = snapshot.galleryOf(widget.artwork.id);
    final selectedId = _galleryId ?? current ?? galleries.first.id;
    final selected = galleries.firstWhere(
      (g) => g.id == selectedId,
      orElse: () => galleries.first,
    );
    final controller = ref.read(collectionProvider.notifier);

    Future<void> save() async {
      final router = GoRouter.of(context);
      final overlay = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop();
      Haptics.play(HapticKind.success);
      await controller.save(widget.artwork.id, selected.id);
      if (!overlay.mounted) return;
      ArtToast.show(
        overlay,
        'Hung in ${selected.name}',
        actionLabel: 'View',
        onAction: () => router.go(AppRoutes.collection),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 58,
                height: 72,
                child: ArtImage(
                  widget.artwork.image,
                  radius: AppRadius.css(29, 29, 3, 3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GoldLabel('Save artwork', tracking: .24),
                    const SizedBox(height: 6),
                    Text(
                      'Hang it in a gallery',
                      style: AppTypography.serif(24),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GalleryPicker(
            galleries: galleries,
            counts: {for (final g in galleries) g.id: snapshot.countIn(g.id)},
            selectedId: selected.id,
            onSelected: (id) => setState(() => _galleryId = id),
            onCreate: (name) async {
              final g = await controller.createGallery(name);
              if (mounted) setState(() => _galleryId = g.id);
            },
          ),
          const SizedBox(height: 12),
          PillButton(label: 'Save to ${selected.name}', onTap: save),
          if (current != null)
            Center(
              child: TextAction(
                label: 'Remove from collection',
                color: p.danger,
                onTap: () {
                  Navigator.of(context).pop();
                  controller.remove(widget.artwork.id);
                },
              ),
            ),
        ],
      ),
    );
  }
}
