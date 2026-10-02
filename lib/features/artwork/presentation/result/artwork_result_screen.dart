import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/overlap_layout.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../collections/presentation/collection_controller.dart';
import '../../../collections/presentation/widgets/save_artwork_sheet.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';
import '../widgets/artwork_metadata.dart';
import 'result_actions.dart';
import 'result_footer.dart';
import 'result_hero.dart';

/// Identification result — the artwork dominates, the label follows.
class ArtworkResultScreen extends ConsumerStatefulWidget {
  const ArtworkResultScreen({super.key, required this.artworkId});

  final String artworkId;

  @override
  ConsumerState<ArtworkResultScreen> createState() =>
      _ArtworkResultScreenState();
}

class _ArtworkResultScreenState extends ConsumerState<ArtworkResultScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(recentlyViewedProvider.notifier).markViewed(widget.artworkId);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artwork = ref.watch(artworkProvider(widget.artworkId));
    final content =
        ref.watch(artworkContentProvider(widget.artworkId)).value ??
        ArtworkContent.empty;
    return ArtScaffold(
      forceLightStatusBar: true,
      body: AsyncView(
        value: artwork,
        onRetry: () => ref.invalidate(artworkProvider(widget.artworkId)),
        data: (a) => _ResultBody(artwork: a, content: content, scroll: _scroll),
      ),
    );
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({
    required this.artwork,
    required this.content,
    required this.scroll,
  });

  final Artwork artwork;
  final ArtworkContent content;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final saved = ref.watch(isSavedProvider(artwork.id));
    final comparison = content.comparison;
    return SingleChildScrollView(
      controller: scroll,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -60,
            top: 380,
            width: 520,
            height: 900,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: Opacity(
                  opacity: .12,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                    child: ArtImage(artwork.image, decodeScale: .25),
                  ),
                ),
              ),
            ),
          ),
          OverlapLayout(
            backdropHeight: 470,
            overlap: 44,
            backdrop: ParallaxHero(artwork: artwork, scroll: scroll),
            foreground: [
              Positioned(
                top: context.topInset,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassIconButton(
                      icon: ArtIcons.chevronLeft,
                      onTap: () => context.backOr(),
                      semanticLabel: 'Back',
                    ),
                    GlassIconButton(
                      icon: ArtIcons.bookmark,
                      iconSize: 17,
                      filled: saved,
                      color: saved ? p.accent : null,
                      onTap: () => showSaveArtworkSheet(context, artwork),
                      semanticLabel: saved
                          ? 'Saved — change gallery'
                          : 'Save artwork',
                    ),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ArtworkMetadata(artwork: artwork),
                  const SizedBox(height: 30),
                  Text(
                    'Discover the story',
                    style: AppTypography.serif(
                      21,
                      italic: true,
                    ).copyWith(color: p.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artwork.summary,
                    style: AppTypography.body.copyWith(color: p.muted),
                  ),
                  const SizedBox(height: 30),
                  ResultActions(artworkId: artwork.id, content: content),
                  if (comparison != null) ...[
                    const SizedBox(height: 22),
                    CompareEntry(artwork: artwork, comparison: comparison),
                  ],
                  const SizedBox(height: 36),
                  const ScanAnotherButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
