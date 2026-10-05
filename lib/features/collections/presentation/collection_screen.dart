import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/router/tab_shell.dart';
import '../../../core/theme/app_motion.dart';
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
import 'widgets/custom_galleries_view.dart';
import 'widgets/remove_artwork_sheet.dart';

const _tabs = [
  'Favorites',
  'Galleries',
  'Recently Viewed',
  'Artists',
  'Museums',
];

/// The visitor's private museum with a fluid, editorial entrance choreography.
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  bool _wasActive = false;
  int _entranceEpoch = 0;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _headerAnimation = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(
      0.00,
      0.55,
      curve: Cubic(0.12, 0.98, 0.24, 1.0),
    ),
  );

  late final Animation<double> _tabsAnimation = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(
      0.10,
      0.65,
      curve: Cubic(0.12, 0.98, 0.24, 1.0),
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentTab = ActiveTabScope.of(context);
    final isActive = currentTab == 1; // branch 1 is Collection

    if (isActive) {
      if (!_wasActive) {
        _wasActive = true;
        _entranceEpoch++;
        if (AppMotion.reduced(context)) {
          _entranceController.value = 1.0;
        } else {
          _entranceController.forward(from: 0.0);
        }
      }
    } else {
      if (_wasActive) {
        _wasActive = false;
        _entranceController.reset();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onTabChanged(int i) {
    if (_tab != i) {
      setState(() {
        _tab = i;
        _entranceEpoch++;
      });
    }
  }

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
            child: AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                final v = _headerAnimation.value;
                if (v >= 1.0) return child!;
                return Opacity(
                  opacity: Curves.easeOutCubic.transform(v.clamp(0.0, 1.0)),
                  child: Transform.translate(
                    offset: Offset(0, 24.0 * (1.0 - v)),
                    child: child,
                  ),
                );
              },
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
                            style:
                                AppTypography.caption.copyWith(color: p.muted),
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
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _tabsAnimation,
              builder: (context, child) {
                final v = _tabsAnimation.value;
                if (v >= 1.0) return child!;
                return Opacity(
                  opacity: Curves.easeOutCubic.transform(v.clamp(0.0, 1.0)),
                  child: Transform.translate(
                    offset: Offset(0, 18.0 * (1.0 - v)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ArtTabs(
                  labels: _tabs,
                  selected: _tab,
                  gap: 22,
                  scrollable: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  onSelected: _onTabChanged,
                ),
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
    final startDelay = _entranceController.value > 0.8
        ? Duration.zero
        : const Duration(milliseconds: 120);

    if (_tab == 0) {
      final works = ref.watch(savedArtworksProvider);
      final list = works.value;
      if (list == null) return const [];
      if (list.isEmpty) {
        return const [SliverToBoxAdapter(child: CollectionEmpty())];
      }
      return [
        CollectionMasonry(
          key: ValueKey('$_tab-$_entranceEpoch'),
          artworks: list,
          rhythm: favoritesRhythm,
          onLongPress: _remove,
          startDelay: startDelay,
        ),
      ];
    } else if (_tab == 1) {
      return [
        SliverToBoxAdapter(
          child: CustomGalleriesView(startDelay: startDelay),
        ),
      ];
    } else if (_tab == 2) {
      final works = ref.watch(recentArtworksProvider);
      final list = works.value;
      if (list == null) return const [];
      if (list.isEmpty) {
        return const [
          SliverToBoxAdapter(
            child: CollectionEmpty(
              lead: 'No recent',
              emphasis: 'explorations yet.',
              message:
                  'Artworks you explore or scan will automatically appear here.',
            ),
          ),
        ];
      }
      return [
        CollectionMasonry(
          key: ValueKey('$_tab-$_entranceEpoch'),
          artworks: list,
          rhythm: recentRhythm,
          startDelay: startDelay,
        ),
      ];
    }

    final grouping = CollectionGrouping.values[_tab - 3];
    final groups = ref.watch(collectionGroupsProvider(grouping)).value;
    if (groups == null) return const [];
    if (groups.isEmpty) {
      return const [SliverToBoxAdapter(child: CollectionEmpty())];
    }
    return [
      CollectionGroupList(
        key: ValueKey('$_tab-$_entranceEpoch'),
        groups: groups,
        grouping: grouping,
        startDelay: startDelay,
      ),
    ];
  }

  void _remove(Artwork a) => showRemoveArtworkSheet(context, a);

  static String _works(int n) => n == 1 ? '1 work' : '$n works';
}
