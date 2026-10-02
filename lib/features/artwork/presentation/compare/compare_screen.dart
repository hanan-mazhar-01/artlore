import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/overlap_layout.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';
import 'compare_widgets.dart';

/// Two works, one lens at a time.
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key, required this.artworkId});

  final String artworkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(artworkProvider(artworkId)).value;
    final content = ref.watch(artworkContentProvider(artworkId));
    final comparison = content.value?.comparison;
    final b = comparison == null
        ? null
        : ref.watch(artworkProvider(comparison.otherId)).value;
    return ArtScaffold(
      forceLightStatusBar: true,
      body: AsyncView(
        value: content,
        data: (_) => a == null || b == null || comparison == null
            ? const SizedBox.expand()
            : _CompareBody(a: a, b: b, comparison: comparison),
      ),
    );
  }
}

class _CompareBody extends StatefulWidget {
  const _CompareBody({
    required this.a,
    required this.b,
    required this.comparison,
  });

  final Artwork a;
  final Artwork b;
  final ArtworkComparison comparison;

  @override
  State<_CompareBody> createState() => _CompareBodyState();
}

class _CompareBodyState extends State<_CompareBody> {
  int _facet = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final facets = widget.comparison.facets;
    final f = facets[_facet];
    final body = AppTypography.bodySmall.copyWith(color: p.muted);
    return SingleChildScrollView(
      child: OverlapLayout(
        backdropHeight: 420,
        overlap: 70,
        backdrop: CompareDiptych(
          a: widget.a,
          b: widget.b,
          focusA: f.focusA,
          focusB: f.focusB,
        ),
        foreground: [
          Positioned(
            top: context.topInset,
            left: 20,
            child: GlassIconButton(
              icon: ArtIcons.chevronLeft,
              onTap: () => context.backOr(),
              semanticLabel: 'Back',
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GoldLabel(
                '${widget.a.artistShort} × ${widget.b.artistShort}',
                size: 11,
                tracking: .32,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final art in [widget.a, widget.b])
                      Flexible(
                        child: Text(
                          '${art.title}, ${art.year}',
                          style: AppTypography.serif(17),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FacetChips(
                labels: [for (final x in facets) x.label],
                selected: _facet,
                onSelected: (i) => setState(() => _facet = i),
              ),
              FadeSlideIn(
                key: ValueKey(_facet),
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: Text(f.textA, style: body)),
                            const SizedBox(width: 18),
                            Container(width: 1, color: p.line(.14)),
                            const SizedBox(width: 18),
                            Expanded(child: Text(f.textB, style: body)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.only(top: 22),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: p.line(.12))),
                        ),
                        child: Text(
                          f.verdict,
                          style: AppTypography.serif(
                            26,
                            italic: true,
                            height: 1.2,
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
      ),
    );
  }
}
