import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/tappable.dart';
import '../collection_views.dart';

/// Ruled rows for Artists, Movements and Museums.
class CollectionGroupList extends StatelessWidget {
  const CollectionGroupList({
    super.key,
    required this.groups,
    required this.grouping,
  });

  final List<CollectionGroup> groups;
  final CollectionGrouping grouping;

  BorderRadius get _thumb => switch (grouping) {
    CollectionGrouping.artists => BorderRadius.circular(26),
    CollectionGrouping.movements => AppRadius.css(4, 18, 4, 18),
    CollectionGrouping.museums => AppRadius.css(26, 26, 3, 3),
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      sliver: SliverList.builder(
        itemCount: groups.length,
        itemBuilder: (context, i) {
          final g = groups[i];
          return FadeSlideIn(
            duration: AppMotion.medium,
            child: Tappable(
              onTap: () => context.openArtwork(g.cover.id),
              semanticLabel: '${g.name}, ${g.count} saved',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: p.line(.1))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: ArtImage(g.cover.image, radius: _thumb),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name,
                            style: AppTypography.serif(21, height: 1.1),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            g.subtitle,
                            style: AppTypography.metadata.copyWith(
                              color: p.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${g.count}',
                      style: AppTypography.serif(
                        22,
                        italic: true,
                      ).copyWith(color: p.accent),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
