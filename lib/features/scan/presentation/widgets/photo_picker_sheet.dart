import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/photo_library.dart';

final _recentPhotosProvider = FutureProvider.autoDispose<List<LibraryPhoto>>(
  (ref) => ref.watch(photoLibraryProvider).recentPhotos(),
);

/// Mock photo picker: recent camera-roll pictures in a quiet grid.
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
          'Pick a picture of an artwork from your camera roll.',
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
        const SizedBox(height: 18),
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
