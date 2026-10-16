import 'dart:ui';

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/providers.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_toast.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/overlap_layout.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../collections/presentation/collection_controller.dart';
import '../../../collections/presentation/widgets/save_artwork_sheet.dart';
import '../../../scan/presentation/scan_arrival.dart';
import '../../../wall/wall_controller.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';
import '../widgets/artwork_metadata.dart';
import '../widgets/info_chips_row.dart';
import '../widgets/story_section.dart';
import 'result_actions.dart';
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
    final onWall = ref.watch(onWallProvider(artwork.id));
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
            // No soft fade here — the rounded sheet below does the whole
            // transition, so its corner cuts cleanly across the painting.
            backdrop: ParallaxHero(
              artwork: artwork,
              scroll: scroll,
              fadeHeight: 0,
            ),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassIconButton(
                          icon: ArtIcons.share,
                          iconSize: 17,
                          onTap: () => _shareArtwork(context, ref, artwork),
                          semanticLabel: 'Share artwork',
                        ),
                        const SizedBox(width: 10),
                        GlassIconButton(
                          icon: ArtIcons.wall,
                          iconSize: 19,
                          color: onWall ? p.accent : null,
                          onTap: () => _toggleWall(context, ref, artwork),
                          semanticLabel: onWall
                              ? 'On your wall — take down'
                              : 'Hang on your wall',
                        ),
                        const SizedBox(width: 10),
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
                  ],
                ),
              ),
            ],
            // A rounded sheet rising over the painting — its top edge is
            // exactly where the content begins, nothing fades in between.
            child: ScanArrivalRise(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: p.shadow.withValues(alpha: p.shadow.a * .6),
                      offset: const Offset(0, -6),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ArtworkMetadata(
                        artwork: artwork,
                        // A work the AI could not name is an interpretation, not
                        // an identification: don't call it one.
                        kicker: artwork.artist == 'Contemporary Eye'
                            ? 'Interpreted by AI'
                            : 'Identified',
                      ),
                      const SizedBox(height: 20),
                      InfoChipsRow(artwork: artwork),
                      const SizedBox(height: 28),
                      StorySection(summary: artwork.summary),
                      const SizedBox(height: 22),
                      ResultActions(artworkId: artwork.id, content: content),
                      const SizedBox(height: 18),
                      Text(
                        'Details and stories are written with the help of AI and '
                        'may contain mistakes.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(color: p.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hangs the painting on the wall, or takes it down if it is already there.
  /// A fourth painting is refused with a popup: the wall holds three.
  Future<void> _toggleWall(
    BuildContext context,
    WidgetRef ref,
    Artwork artwork,
  ) async {
    final wall = ref.read(wallProvider.notifier);
    if (wall.contains(artwork.id)) {
      wall.remove(artwork.id);
      HapticFeedback.selectionClick();
      ArtToast.show(context, 'Taken down from your wall');
      return;
    }
    // A guest is asked to make an account first: the wall is for accounts.
    final isGuest =
        ref.read(authServiceProvider).currentUser?.isAnonymous ?? false;
    if (isGuest) {
      final signedUp = await context.push<bool>(
        AppRoutes.accountWall,
        extra: 'wall',
      );
      if (signedUp != true || !context.mounted) return;
    }
    switch (wall.hang(artwork.id)) {
      case HangResult.hung:
        HapticFeedback.mediumImpact();
        ArtToast.show(context, 'Hung on your wall');
      case HangResult.full:
        HapticFeedback.heavyImpact();
        showWallFullDialog(context);
      case HangResult.alreadyThere:
        break;
    }
  }

  void _shareArtwork(BuildContext context, WidgetRef ref, Artwork artwork) {
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final baseUrl = remoteConfig.shareArtworkBaseUrl.replaceAll(
      RegExp(r'/+$'),
      '',
    );
    final webUrl = '$baseUrl/${artwork.id}';
    final deepLink = 'artlore://artwork/${artwork.id}';

    final text =
        'Discover "${artwork.title}" by ${artwork.artist} on ArtLore!\n\n'
        'Open in ArtLore: $deepLink\n'
        'Explore online: $webUrl';

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'Explore ${artwork.title} on ArtLore',
        title: artwork.title,
        sharePositionOrigin: origin,
      ),
    );
  }
}

/// On arrival from a scan, lifts [child] up from below as the page fades in.
/// Otherwise it does nothing at all.
class ScanArrivalRise extends StatefulWidget {
  const ScanArrivalRise({super.key, required this.child});

  final Widget child;

  @override
  State<ScanArrivalRise> createState() => _ScanArrivalRiseState();
}

class _ScanArrivalRiseState extends State<ScanArrivalRise> {
  late final bool _arrived = ScanArrival.take();

  @override
  Widget build(BuildContext context) {
    if (!_arrived) return widget.child;
    final route = ModalRoute.of(context)?.animation;
    if (route == null) return widget.child;
    final rise = CurvedAnimation(
      parent: route,
      // The picture glides first; the sheet follows it up.
      curve: const Interval(.3, 1, curve: Cubic(.16, 1, .3, 1)),
    );
    final height = MediaQuery.sizeOf(context).height;
    return AnimatedBuilder(
      animation: rise,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (1 - rise.value) * height * .55),
        child: child,
      ),
    );
  }
}
