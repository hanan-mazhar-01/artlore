import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/art_sheet.dart';
import '../../../core/widgets/round_buttons.dart';
import '../../artwork/domain/artwork.dart';
import '../../home/presentation/home_providers.dart';
import '../../home/presentation/widgets/home_search.dart';
import '../../home/presentation/widgets/home_style.dart';

/// Search, on its own page: the field takes focus at once, with the All /
/// Scans / Collection / Artists chips and live results beneath, and the round
/// filter button for sort and movement.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.openFilters = false});

  /// Arrived from Home's filter button: show the sort & filter sheet first.
  final bool openFilters;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  HomeFilter _filter = HomeFilter.all;
  HomeSort _sort = HomeSort.newest;
  String? _movement;

  @override
  void initState() {
    super.initState();
    if (widget.openFilters) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFilters(ref.read(homeSearchPoolProvider));
      });
    }
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _query.clear();
    setState(() {
      _filter = HomeFilter.all;
      _sort = HomeSort.newest;
      _movement = null;
    });
  }

  /// Opens the sort & filter sheet; changes apply live behind it.
  Future<void> _openFilters(HomeSearchPool pool) {
    _focus.unfocus();
    final movements = {
      for (final a in [...pool.scans, ...pool.saved])
        if (a.movement.trim().isNotEmpty) a.movement,
    }.toList()..sort();
    return showArtSheet<void>(
      context,
      child: HomeFilterSheet(
        sort: _sort,
        movement: _movement,
        movements: movements,
        onChanged: (sort, movement) => setState(() {
          _sort = sort;
          _movement = movement;
        }),
      ),
    );
  }

  List<HomeSearchResult> _results(HomeSearchPool pool) {
    final q = _query.text.trim().toLowerCase();

    bool matches(Artwork a) {
      if (_movement != null && a.movement != _movement) return false;
      if (q.isEmpty) return true;
      if (_filter == HomeFilter.artists) {
        return a.artist.toLowerCase().contains(q);
      }
      final hay = '${a.title} ${a.artist} ${a.movement} ${a.city} ${a.summary}'
          .toLowerCase();
      return hay.contains(q);
    }

    List<HomeSearchResult> found;
    if (_filter == HomeFilter.artists) {
      final seen = <String>{};
      found = [
        for (final a in [...pool.scans, ...pool.saved])
          if (matches(a) && seen.add(a.artist)) HomeSearchResult(a, 'Artist'),
      ];
    } else {
      found = [
        if (_filter == HomeFilter.all || _filter == HomeFilter.scans)
          for (final a in pool.scans)
            if (matches(a)) HomeSearchResult(a, 'Scan'),
        if (_filter == HomeFilter.all || _filter == HomeFilter.collection)
          for (final a in pool.saved)
            if (matches(a)) HomeSearchResult(a, 'Saved'),
      ];
    }
    switch (_sort) {
      case HomeSort.newest:
        break; // already newest first
      case HomeSort.title:
        found.sort(
          (a, b) => a.artwork.title.toLowerCase().compareTo(
            b.artwork.title.toLowerCase(),
          ),
        );
      case HomeSort.artist:
        found.sort(
          (a, b) => a.artwork.artist.toLowerCase().compareTo(
            b.artwork.artist.toLowerCase(),
          ),
        );
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final pool = ref.watch(homeSearchPoolProvider);
    return ArtScaffold(
      background: HomeStyle.of(context).ground,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, context.topInset + 4, 22, 0),
                child: Row(
                  children: [
                    OutlineIconButton(onTap: () => context.backOr()),
                    const SizedBox(width: 14),
                    Text(
                      'Search',
                      style: AppTypography.serif(
                        30,
                        weight: FontWeight.w700,
                      ).copyWith(color: s.ink),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: HomeSearchBar(
                controller: _query,
                focusNode: _focus,
                focused: true,
                autofocus: !widget.openFilters,
                onChanged: (_) => setState(() {}),
                onClear: _clear,
                onFilters: () => _openFilters(pool),
                filtersActive: _sort != HomeSort.newest || _movement != null,
              ),
            ),
            SliverToBoxAdapter(
              child: HomeSearchResults(
                filter: _filter,
                onFilter: (f) => setState(() => _filter = f),
                results: _results(pool),
                query: _query.text,
                onOpen: (a) => context.openArtwork(a.id),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.tabBarClearance),
            ),
          ],
        ),
      ),
    );
  }
}
