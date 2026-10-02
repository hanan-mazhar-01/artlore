import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/art_tabs.dart';
import '../../../core/widgets/buttons.dart';
import '../../artwork/domain/artwork.dart';
import 'collection_controller.dart';
import 'collection_views.dart';
import 'widgets/collection_empty.dart';
import 'widgets/collection_group_list.dart';
import 'widgets/collection_masonry.dart';
import 'widgets/remove_artwork_sheet.dart';

const _tabs = [
  'Favorites',
  'Recently Viewed',
  'Artists',
  'Movements',
  'Museums',
];

/// The visitor's private museum.
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final summary = ref.watch(
      collectionProvider.select((c) {
        final v = c.value;
        return v == null ? null : (v.saved.length, v.galleries.length);
      }),
    );
    return ArtScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, context.topInset, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Collection',
                            style: AppTypography.serif(
                              44,
                              weight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary == null
                              ? ' '
                              : '${_works(summary.$1)} · '
                                    '${summary.$2} galleries',
                          style: AppTypography.caption.copyWith(color: p.muted),
                        ),
                      ],
                    ),
                  ),
                  TextAction(
                    label: 'History →',
                    color: p.accent,
                    fontSize: 12,
                    padding: const EdgeInsets.only(bottom: 4, top: 8),
                    onTap: () => context.push(AppRoutes.history),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ArtTabs(
                labels: _tabs,
                selected: _tab,
                gap: 22,
                scrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                onSelected: (i) => setState(() => _tab = i),
              ),
            ),
          ),
          ..._body(),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.tabBarClearance),
          ),
        ],
      ),
    );
  }

  List<Widget> _body() {
    if (_tab < 2) {
      final favorites = _tab == 0;
      final works = ref.watch(
        favorites ? savedArtworksProvider : recentArtworksProvider,
      );
      final list = works.value;
      if (list == null) return const [];
      if (list.isEmpty && favorites) {
        return const [SliverToBoxAdapter(child: CollectionEmpty())];
      }
      return [
        CollectionMasonry(
          key: ValueKey(_tab),
          artworks: list,
          rhythm: favorites ? favoritesRhythm : recentRhythm,
          onLongPress: favorites ? _remove : null,
        ),
      ];
    }
    final grouping = CollectionGrouping.values[_tab - 2];
    final groups = ref.watch(collectionGroupsProvider(grouping)).value;
    if (groups == null) return const [];
    if (groups.isEmpty) {
      return const [SliverToBoxAdapter(child: CollectionEmpty())];
    }
    return [
      CollectionGroupList(
        key: ValueKey(grouping),
        groups: groups,
        grouping: grouping,
      ),
    ];
  }

  void _remove(Artwork a) => showRemoveArtworkSheet(context, a);

  static String _works(int n) => n == 1 ? '1 work' : '$n works';
}
