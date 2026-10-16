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
import '../../../home/presentation/widgets/photo_liftoff.dart';
import '../ai_consent.dart';
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
        const _Reveal(
          start: .16,
          child: GoldLabel('Scan from Photos', tracking: .24),
        ),
        const SizedBox(height: 6),
        _Reveal(
          start: .22,
          child: Text('Choose a photograph', style: AppTypography.serif(26)),
        ),
        const SizedBox(height: 4),
        _Reveal(
          start: .28,
          child: Text(
            'Pick a picture of an artwork from your camera roll or device gallery.',
            style: AppTypography.caption.copyWith(color: p.muted),
          ),
        ),
        const SizedBox(height: 16),
        _Reveal(
          start: .34,
          dy: 34,
          child: Tappable(
            onTap: () async {
              // A photo of your own goes to an AI service: ask first, once.
              if (!await ensureAiConsent(context, ref)) return;
              if (!context.mounted) return;
              try {
                final picker = ImagePicker();
                // A phone photo can be several megabytes; the AI needs far less
                // to recognise a painting, and a smaller upload is faster.
                final xFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1600,
                  maxHeight: 1600,
                  imageQuality: 85,
                );
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
              height: 80,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The flying cards come to rest here.
                  const PhotoLandingSlot(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Choose from Device Gallery',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sans(
                        14,
                        weight: FontWeight.w600,
                      ).copyWith(color: p.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Reveal(
          start: .42,
          child: Text(
            'Or select a museum piece:',
            style: AppTypography.caption.copyWith(color: p.muted),
          ),
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
                  itemBuilder: (context, i) => _TileReveal(
                    index: i,
                    child: Tappable(
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
        ),
      ],
    );
  }
}

/// The sheet's rise, as a 0–1 value: the route's own animation, so everything
/// inside moves with — and reverses with — the sheet.
Animation<double> _riseOf(BuildContext context) =>
    ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;

/// A line that floats up into place and fades in, starting [start] of the way
/// through the sheet's rise.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.start, required this.child, this.dy = 28});

  final double start;
  final double dy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rise = _riseOf(context);
    final curve = Interval(
      start,
      (start + .3).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: rise,
      child: child,
      builder: (context, child) {
        final t = curve.transform(rise.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * dy),
            child: child,
          ),
        );
      },
    );
  }
}

/// A photo tile that drops in from above, where the floating cards went:
/// turning a little as it falls, overshooting slightly, then settling.
class _TileReveal extends StatelessWidget {
  const _TileReveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rise = _riseOf(context);
    final start = (.46 + index * .045).clamp(0.0, .68);
    final curve = Interval(
      start,
      (start + .32).clamp(0.0, 1.0),
      curve: Curves.easeOutBack,
    );
    final turn = (index.isEven ? -1 : 1) * .24;
    return AnimatedBuilder(
      animation: rise,
      child: child,
      builder: (context, child) {
        final t = curve.transform(rise.value);
        return Opacity(
          opacity: (t * 2.4).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -(1 - t) * 120),
            child: Transform.rotate(
              angle: turn * (1 - t),
              child: Transform.scale(scale: .5 + .5 * t, child: child),
            ),
          ),
        );
      },
    );
  }
}
