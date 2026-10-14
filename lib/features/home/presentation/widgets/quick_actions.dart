import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import 'home_style.dart';

/// Two cards under the hero: scan from the photo library (light) and the
/// visitor's collection (dark, with its first few covers).
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onScanPhotos,
    required this.onCollection,
    required this.savedCount,
    this.thumbs = const [],
    this.latestPhoto,
  });

  final VoidCallback onScanPhotos;
  final VoidCallback onCollection;

  /// Number of saved works, or null while it loads.
  final int? savedCount;

  /// Up to three cover images from the collection, newest first.
  final List<ArtImageSource> thumbs;

  /// The newest photo in the phone's library, if access was granted.
  final Uint8List? latestPhoto;

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final count = savedCount ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: _PhotosCard(
              style: s,
              onTap: onScanPhotos,
              photo: latestPhoto,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CollectionCard(
              style: s,
              onTap: onCollection,
              thumbs: thumbs.take(3).toList(),
              label: count > 0
                  ? '$count ${count == 1 ? 'work' : 'works'} saved'
                  : 'Start your collection',
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({
    required this.style,
    required this.onTap,
    required this.photo,
  });

  final HomeStyle style;
  final VoidCallback onTap;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Tappable(
      onTap: onTap,
      semanticLabel: 'Scan from Photos',
      pressedScale: .97,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: s.line),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.35),
              offset: const Offset(0, 10),
              blurRadius: 24,
              spreadRadius: -18,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -42,
              top: -42,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: s.line),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (photo != null)
                      Container(
                        width: 42,
                        height: 54,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: s.tile,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: s.gold.withValues(alpha: .6),
                          ),
                        ),
                        child: Image.memory(
                          photo!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          excludeFromSemantics: true,
                        ),
                      )
                    else
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: s.goldTint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ArtIcon(
                          ArtIcons.photos,
                          size: 20,
                          color: s.goldDeep,
                        ),
                      ),
                    ArtIcon(
                      ArtIcons.arrowUpRight,
                      size: 18,
                      color: s.muted,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Scan from Photos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sans(
                    14.5,
                    weight: FontWeight.w700,
                  ).copyWith(color: s.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  'Discover art from your gallery',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sans(
                    12,
                    weight: FontWeight.w500,
                    height: 1.35,
                  ).copyWith(color: s.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.style,
    required this.onTap,
    required this.thumbs,
    required this.label,
  });

  final HomeStyle style;
  final VoidCallback onTap;
  final List<ArtImageSource> thumbs;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Tappable(
      onTap: onTap,
      semanticLabel: 'My Collection',
      pressedScale: .97,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.6),
              offset: const Offset(0, 14),
              blurRadius: 26,
              spreadRadius: -16,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumbs.isNotEmpty)
                  SizedBox(
                    height: 40,
                    width: 30.0 + (thumbs.length - 1) * 20,
                    child: Stack(
                      children: [
                        for (var i = 0; i < thumbs.length; i++)
                          Positioned(
                            left: i * 20.0,
                            child: Container(
                              width: 30,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A352F),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: s.card, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x73D9B46E),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ArtImage(
                                thumbs[i],
                                radius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x29D9B46E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ArtIcon(ArtIcons.gallery, size: 20, color: s.goldDeep),
                  ),
                ArtIcon(ArtIcons.arrowUpRight, size: 18, color: s.goldDeep),
              ],
            ),
            const Spacer(),
            Text(
              'My Collection',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sans(
                14.5,
                weight: FontWeight.w700,
              ).copyWith(color: s.ink),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sans(
                12,
                weight: FontWeight.w500,
                height: 1.35,
              ).copyWith(color: s.ink.withValues(alpha: .72)),
            ),
          ],
        ),
      ),
    );
  }
}
