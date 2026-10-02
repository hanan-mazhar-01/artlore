import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_sheet.dart';
import '../../../../core/widgets/art_toast.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../artwork/domain/artwork.dart';
import '../collection_controller.dart';

/// Long-press on a saved work: take it down from the wall.
Future<void> showRemoveArtworkSheet(BuildContext context, Artwork artwork) {
  return showArtSheet<void>(
    context,
    child: _RemoveArtworkSheet(artwork: artwork),
  );
}

class _RemoveArtworkSheet extends ConsumerWidget {
  const _RemoveArtworkSheet({required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 58,
              height: 72,
              child: ArtImage(
                artwork.image,
                radius: AppRadius.css(29, 29, 3, 3),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GoldLabel('In your collection', tracking: .24),
                  const SizedBox(height: 6),
                  Text(artwork.title, style: AppTypography.serif(24)),
                  Text(
                    artwork.byline,
                    style: AppTypography.metadata.copyWith(color: p.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        PillButton(
          label: 'Take it down',
          onTap: () {
            // Captured now: the sheet (and its ref) is gone by the time
            // the visitor taps Undo.
            final collection = ref.read(collectionProvider.notifier);
            final gallery = ref
                .read(collectionProvider)
                .value
                ?.galleryOf(artwork.id);
            final overlay = Navigator.of(context, rootNavigator: true).context;
            Navigator.of(context).pop();
            collection.remove(artwork.id);
            ArtToast.show(
              overlay,
              'Removed from your collection',
              actionLabel: gallery == null ? null : 'Undo',
              onAction: gallery == null
                  ? null
                  : () => collection.save(artwork.id, gallery),
            );
          },
        ),
        Center(
          child: TextAction(
            label: 'Keep it',
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
