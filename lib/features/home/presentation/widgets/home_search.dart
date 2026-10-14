import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/domain/artwork.dart';
import 'home_style.dart';

/// Which slice of the visitor's art the search looks through.
enum HomeFilter {
  all('All'),
  scans('Scans'),
  collection('Collection'),
  artists('Artists');

  const HomeFilter(this.label);
  final String label;
}

/// Order of the results list.
enum HomeSort {
  newest('Newest first'),
  title('Title A–Z'),
  artist('Artist A–Z');

  const HomeSort(this.label);
  final String label;
}

/// One row of search results.
class HomeSearchResult {
  const HomeSearchResult(this.artwork, this.source);

  final Artwork artwork;

  /// "Scan", "Saved" or "Artist".
  final String source;
}

/// The search field with its round filter button.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.focused = false,
    this.onChanged,
    this.onClear,
    required this.onFilters,
    this.onOpen,
    this.autofocus = false,
    this.padding = const EdgeInsets.fromLTRB(22, 18, 22, 0),
    this.filtersActive = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool focused;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback onFilters;

  /// When set, the field is a button: it shows the hint and opens search on
  /// tap instead of taking text itself (as on Home).
  final VoidCallback? onOpen;
  final bool autofocus;
  final EdgeInsets padding;

  /// A sort or movement filter is applied — shown as a gold dot.
  final bool filtersActive;

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final hasText = controller?.text.isNotEmpty ?? false;
    final launcher = onOpen != null;
    final hint = AppTypography.sans(
      14,
      weight: FontWeight.w500,
    ).copyWith(color: s.muted);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: s.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: focused ? s.gold : s.line),
              ),
              child: Row(
                children: [
                  ArtIcon(ArtIcons.search, size: 18, color: s.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: launcher
                        ? Tappable(
                            onTap: onOpen,
                            semanticLabel:
                                'Search paintings, artists, or stories',
                            pressedScale: 1,
                            child: SizedBox(
                              height: 50,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Search paintings, artists, or stories...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: hint,
                                ),
                              ),
                            ),
                          )
                        : TextField(
                            autofocus: autofocus,
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: onChanged,
                            textInputAction: TextInputAction.search,
                            cursorColor: s.gold,
                            style: AppTypography.sans(
                              14,
                              weight: FontWeight.w500,
                            ).copyWith(color: s.ink),
                            decoration: InputDecoration.collapsed(
                              hintText:
                                  'Search paintings, artists, or stories...',
                              hintStyle: AppTypography.sans(
                                14,
                                weight: FontWeight.w500,
                              ).copyWith(color: s.muted),
                            ),
                          ),
                  ),
                  if (!launcher && (hasText || focused))
                    Tappable(
                      onTap: onClear,
                      semanticLabel: 'Clear search',
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: s.tile,
                          shape: BoxShape.circle,
                        ),
                        child: ArtIcon(
                          ArtIcons.close,
                          size: 11,
                          color: s.muted,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Tappable(
            onTap: onFilters,
            semanticLabel: 'Sort and filter',
            pressedScale: .94,
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: s.deep,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: s.shadow(.6),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ArtIcon(ArtIcons.filter, size: 20, color: s.onDeepAccent),
                  if (filtersActive)
                    Positioned(
                      top: -9,
                      right: -9,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: s.gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: s.deep, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chips, result count and the list (or the "nothing matches" note).
class HomeSearchResults extends StatelessWidget {
  const HomeSearchResults({
    super.key,
    required this.filter,
    required this.onFilter,
    required this.results,
    required this.query,
    required this.onOpen,
  });

  final HomeFilter filter;
  final ValueChanged<HomeFilter> onFilter;
  final List<HomeSearchResult> results;
  final String query;
  final ValueChanged<Artwork> onOpen;

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final searching = query.trim().isNotEmpty;
    final label = searching
        ? '${results.length} result${results.length == 1 ? '' : 's'}'
        : (results.isNotEmpty ? 'From your scans & collection' : '');
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in HomeFilter.values)
                _Chip(
                  label: f.label,
                  active: f == filter,
                  onTap: () => onFilter(f),
                ),
            ],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              label.toUpperCase(),
              style: AppTypography.sans(
                10.5,
                weight: FontWeight.w600,
                tracking: .15,
              ).copyWith(color: s.muted),
            ),
          ],
          const SizedBox(height: 14),
          for (final r in results) ...[
            _ResultRow(result: r, onTap: () => onOpen(r.artwork)),
            const SizedBox(height: 8),
          ],
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      searching ? 'Nothing matches “$query”' : 'Nothing yet',
                      textAlign: TextAlign.center,
                      style: AppTypography.serif(
                        22,
                        weight: FontWeight.w700,
                      ).copyWith(color: s.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try an artist, a title, or a theme like “night”.',
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        13,
                        weight: FontWeight.w500,
                      ).copyWith(color: s.muted),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      pressedScale: .96,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? s.deep : s.ground,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: active ? s.deep : s.line),
        ),
        // A shrink-wrapped row (not `alignment`, which would stretch the chip
        // to the full width of the Wrap).
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.sans(
                12.5,
                weight: FontWeight.w600,
              ).copyWith(color: active ? s.onDeep : s.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.onTap});

  final HomeSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final a = result.artwork;
    return Tappable(
      onTap: onTap,
      semanticLabel: '${a.title}, ${a.artist}',
      pressedScale: .98,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: s.line),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: ArtImage(
                a.image,
                radius: BorderRadius.circular(12),
                alignment: a.heroFocus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.serif(
                      18,
                      weight: FontWeight.w700,
                      height: 1.15,
                    ).copyWith(color: s.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      12.5,
                      weight: FontWeight.w500,
                    ).copyWith(color: s.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: s.goldTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                result.source.toUpperCase(),
                style: AppTypography.sans(
                  10,
                  weight: FontWeight.w600,
                  tracking: .08,
                ).copyWith(color: s.goldDeep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet content for the round filter button: how to order results and
/// which movement to keep. Changes apply live behind the sheet.
class HomeFilterSheet extends StatefulWidget {
  const HomeFilterSheet({
    super.key,
    required this.sort,
    required this.movement,
    required this.movements,
    required this.onChanged,
  });

  final HomeSort sort;
  final String? movement;
  final List<String> movements;
  final void Function(HomeSort sort, String? movement) onChanged;

  @override
  State<HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<HomeFilterSheet> {
  late HomeSort _sort = widget.sort;
  late String? _movement = widget.movement;

  void _set(HomeSort sort, String? movement) {
    setState(() {
      _sort = sort;
      _movement = movement;
    });
    widget.onChanged(sort, movement);
  }

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final changed = _sort != HomeSort.newest || _movement != null;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.sans(
          10.5,
          weight: FontWeight.w600,
          tracking: .15,
        ).copyWith(color: s.muted),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Sort & filter',
                style: AppTypography.serif(
                  26,
                  weight: FontWeight.w700,
                ).copyWith(color: s.ink),
              ),
            ),
            if (changed)
              Tappable(
                onTap: () => _set(HomeSort.newest, null),
                semanticLabel: 'Reset sort and filter',
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    'Reset',
                    style: AppTypography.sans(
                      13,
                      weight: FontWeight.w600,
                    ).copyWith(color: s.goldDeep),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        heading('Sort by'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in HomeSort.values)
              _Chip(
                label: o.label,
                active: o == _sort,
                onTap: () => _set(o, _movement),
              ),
          ],
        ),
        if (widget.movements.isNotEmpty) ...[
          const SizedBox(height: 22),
          heading('Movement'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: 'Any',
                active: _movement == null,
                onTap: () => _set(_sort, null),
              ),
              for (final m in widget.movements)
                _Chip(
                  label: m,
                  active: m == _movement,
                  onTap: () => _set(_sort, m),
                ),
            ],
          ),
        ],
        const SizedBox(height: 26),
        Tappable(
          onTap: () => Navigator.of(context).pop(),
          semanticLabel: 'Show results',
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: s.deep,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'Show results',
              style: AppTypography.sans(
                14.5,
                weight: FontWeight.w700,
              ).copyWith(color: s.onDeep),
            ),
          ),
        ),
      ],
    );
  }
}
