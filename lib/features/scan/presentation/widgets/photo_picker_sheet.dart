import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/providers.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/data/dynamic_artwork_storage.dart';
import '../../domain/photo_library.dart';
import '../scan_controller.dart';

final _recentPhotosProvider = FutureProvider.autoDispose<List<LibraryPhoto>>(
  (ref) => ref.watch(photoLibraryProvider).recentPhotos(),
);

/// Photo picker: allows picking from real device gallery or sample works.
/// Pops with the chosen photo id.
class PhotoPickerSheet extends ConsumerWidget {
  const PhotoPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final photos = ref.watch(_recentPhotosProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const GoldLabel('Scan from Photos', tracking: .24),
        const SizedBox(height: 6),
        Text('Choose a photograph', style: AppTypography.serif(26)),
        const SizedBox(height: 4),
        Text(
          'Pick a picture of an artwork from your camera roll or device gallery.',
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
        const SizedBox(height: 16),
        Tappable(
          onTap: () async {
            try {
              final picker = ImagePicker();
              final xFile = await picker.pickImage(source: ImageSource.gallery);
              if (xFile != null && context.mounted) {
                final bytes = await xFile.readAsBytes();
                ref.read(pendingFrameBytesProvider.notifier).state = bytes;
                if (!context.mounted) return;
                // Unique per photo's actual content — a constant id here
                // would make every device-gallery pick share the same
                // analysisControllerProvider family entry, so a second,
                // different photo could show a first one's cached result.
                final id = 'device-${DynamicArtworkStorage.hashOf(bytes)}';
                Navigator.of(context).pop(id);
              }
            } catch (e) {
              debugPrint('ImagePicker error: $e');
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 18, color: p.accent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Choose from Device Gallery',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(14, weight: FontWeight.w600)
                        .copyWith(color: p.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Or select a museum piece:',
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 236,
          child: photos == null
              ? null
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: photos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) => Tappable(
                    onTap: () => Navigator.of(context).pop(photos[i].id),
                    semanticLabel: 'Photo ${i + 1}',
                    pressedScale: .95,
                    child: ArtImage(
                      photos[i].image,
                      radius: BorderRadius.circular(i.isEven ? 14 : 4),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
