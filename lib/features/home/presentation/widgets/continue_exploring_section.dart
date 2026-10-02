import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import '../home_providers.dart';

/// "Continue exploring" — the works the visitor already opened, set larger
/// than the scan rail: one lead image, then two side by side.
class ContinueExploringSection extends ConsumerWidget {
  const ContinueExploringSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final works = ref.watch(continueExploringProvider).value;
    if (works == null || works.isEmpty) return const SizedBox.shrink();
    final rest = works.skip(1).take(2).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Continue exploring'),
          const SizedBox(height: 18),
          _ExploreTile(
            artwork: works.first,
            height: 220,
            radius: AppRadius.sweep,
            titleSize: 24,
            showLink: true,
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < rest.length; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  Expanded(
                    child: _ExploreTile(
                      artwork: rest[i],
                      height: i == 0 ? 190 : 160,
                      radius: i == 0 ? AppRadius.arch : AppRadius.leaf,
                      titleSize: 18,
                    ),
                  ),
                ],
                if (rest.length == 1) const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.artwork,
    required this.height,
    required this.radius,
    required this.titleSize,
    this.showLink = false,
  });

  final Artwork artwork;
  final double height;
  final BorderRadius radius;
  final double titleSize;
  final bool showLink;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: () => context.openArtwork(artwork.id),
      semanticLabel: 'Continue: ${artwork.semanticLabel}',
      pressedScale: .99,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: ArtImage(
              artwork.image,
              radius: radius,
              alignment: artwork.heroFocus,
              semanticLabel: artwork.semanticLabel,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            artwork.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.serif(titleSize, height: 1.1),
          ),
          const SizedBox(height: 3),
          Text(
            artwork.byline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.metadata.copyWith(color: p.muted),
          ),
          if (showLink) ...[
            const SizedBox(height: 10),
            const ArrowLink(label: 'Continue the story'),
          ],
        ],
      ),
    );
  }
}
