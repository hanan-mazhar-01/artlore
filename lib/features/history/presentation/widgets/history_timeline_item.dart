import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/presentation/artwork_providers.dart';
import '../../domain/history_entry.dart';

const _shapes = [ArtShape.arch, ArtShape.soft, ArtShape.round, ArtShape.leaf];

/// One stop on the timeline. Each item draws its own stretch of the thread
/// so the list stays lazily built.
class HistoryTimelineItem extends ConsumerWidget {
  const HistoryTimelineItem({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.shapeIndex,
  });

  final HistoryEntry entry;
  final bool isFirst;
  final int shapeIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final artwork = ref.watch(artworkProvider(entry.artworkId)).value;
    final ring = isFirst ? p.accent : p.muted;
    return Stack(
      children: [
        Positioned(
          left: 7,
          top: isFirst ? 30 : 0,
          bottom: 0,
          width: 1,
          child: ColoredBox(color: p.line(.12)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: ring),
                    ),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: ring,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: GoldLabel(
                      DateLabels.relative(entry.at),
                      tracking: .24,
                      color: ring,
                    ),
                  ),
                ],
              ),
              if (artwork != null)
                Tappable(
                  onTap: () => context.openArtwork(artwork.id),
                  semanticLabel: artwork.semanticLabel,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, top: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 74,
                          height: 90,
                          child: ArtImage(
                            artwork.image,
                            radius: _shapes[shapeIndex % _shapes.length].radius,
                            alignment: artwork.heroFocus,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artwork.title,
                                  style: AppTypography.serif(21, height: 1.05),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.where,
                                  style: AppTypography.metadata.copyWith(
                                    color: p.muted,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  entry.activity,
                                  style: AppTypography.caption.copyWith(
                                    color: p.ink.withValues(alpha: .75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
