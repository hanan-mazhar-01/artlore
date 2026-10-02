import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/presentation/artwork_providers.dart';
import '../../../history/domain/history_entry.dart';
import '../home_providers.dart';

/// Frames cycled along the rail so neighbours never match.
const _rhythm = [
  (width: 132.0, height: 172.0, shape: ArtShape.arch),
  (width: 168.0, height: 128.0, shape: ArtShape.soft),
  (width: 140.0, height: 152.0, shape: ArtShape.leaf),
];

/// "Recent scans" — the visitor's latest identifications, newest first.
class RecentScansSection extends ConsumerWidget {
  const RecentScansSection({super.key, required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scans = ref.watch(recentScansProvider);
    final caption = MediaQuery.textScalerOf(context).scale(76);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: SectionHeader(
            title: 'Recent scans',
            action: scans == null || scans.isEmpty ? null : 'See all',
            onAction: () => context.push(AppRoutes.history),
          ),
        ),
        const SizedBox(height: 16),
        if (scans == null)
          SizedBox(height: 172 + caption)
        else if (scans.isEmpty)
          _EmptyScans(onScan: onScan)
        else
          SizedBox(
            height: 172 + caption,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: scans.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => FadeSlideIn(
                axis: Axis.horizontal,
                offset: 24,
                delay: Duration(milliseconds: 70 * i.clamp(0, 5)),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RecentArtworkCard(entry: scans[i], index: i),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One scanned work: its frame, when, what, who.
class RecentArtworkCard extends ConsumerWidget {
  const RecentArtworkCard({
    super.key,
    required this.entry,
    required this.index,
  });

  final HistoryEntry entry;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final spec = _rhythm[index % _rhythm.length];
    final artwork = ref.watch(artworkProvider(entry.artworkId)).value;
    if (artwork == null) return SizedBox(width: spec.width);
    return SizedBox(
      width: spec.width,
      child: Tappable(
        onTap: () => context.openArtwork(artwork.id),
        semanticLabel:
            '${artwork.semanticLabel}, scanned '
            '${DateLabels.ago(entry.at)}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: spec.height,
              width: double.infinity,
              child: ArtImage(
                artwork.image,
                radius: spec.shape.radius,
                alignment: artwork.heroFocus,
              ),
            ),
            const SizedBox(height: 10),
            GoldLabel(DateLabels.ago(entry.at), tracking: .2, maxLines: 1),
            const SizedBox(height: 5),
            Text(
              artwork.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.serif(17, height: 1.1),
            ),
            const SizedBox(height: 2),
            Text(
              artwork.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.metadata.copyWith(color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScans extends StatelessWidget {
  const _EmptyScans({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        borderRadius: AppRadius.css(6, 48, 6, 6),
        border: Border.all(color: p.line(.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your gallery is waiting.',
            style: AppTypography.serif(26, italic: true),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan your first artwork to begin your collection.',
            style: AppTypography.sans(13, height: 1.5).copyWith(color: p.muted),
          ),
          const SizedBox(height: 18),
          PillButton(
            label: 'Scan Artwork',
            onTap: onScan,
            style: PillStyle.outline,
            height: 48,
            fontSize: 14,
            trailingArrow: true,
          ),
        ],
      ),
    );
  }
}
