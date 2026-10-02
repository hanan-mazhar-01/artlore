import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_controls.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';
import 'listen_controller.dart';
import 'listen_player.dart';

/// The audio guide — narrated story in three lengths.
class ListenScreen extends ConsumerWidget {
  const ListenScreen({super.key, required this.artworkId});

  final String artworkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artwork = ref.watch(artworkProvider(artworkId)).value;
    final content = ref.watch(artworkContentProvider(artworkId));
    return ArtScaffold(
      body: AsyncView(
        value: content,
        data: (c) => artwork == null || c.narration == null
            ? const SizedBox.expand()
            : _ListenBody(artwork: artwork, narration: c.narration!),
      ),
    );
  }
}

class _ListenBody extends ConsumerWidget {
  const _ListenBody({required this.artwork, required this.narration});

  final Artwork artwork;
  final Narration narration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final provider = listenControllerProvider(narration);
    // Only what this layout shows — the scrubber watches the clock itself.
    final mode = ref.watch(provider.select((s) => s.mode));
    final playing = ref.watch(provider.select((s) => s.playing));
    final chapterIndex = ref.watch(
      provider.select((s) => ListenController.chapterAt(narration, s)),
    );
    final chapter = narration.chapters[chapterIndex];
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: Opacity(
              opacity: .22,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: ArtImage(artwork.image, decodeScale: .25),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.ground(.3), p.background],
                stops: const [0, .75],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, context.topInset, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    icon: ArtIcons.chevronDown,
                    onTap: () => context.backOr(),
                    semanticLabel: 'Close audio guide',
                  ),
                  Flexible(
                    child: GoldLabel(
                      'Audio guide · Stop ${narration.stop}',
                      color: p.muted,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: AnimatedScale(
                  scale: playing ? 1.04 : 1,
                  duration: AppMotion.slow,
                  curve: AppMotion.reveal,
                  child: SizedBox(
                    width: 220,
                    height: 280,
                    child: ArtImage(
                      artwork.image,
                      radius: AppRadius.css(110, 110, 4, 4),
                      shadow: AppShadows.artwork(p),
                      semanticLabel: artwork.semanticLabel,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                artwork.title,
                style: AppTypography.serif(
                  32,
                  weight: FontWeight.w500,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${artwork.artist} · narrated by ${narration.narrator}',
                style: AppTypography.sans(13).copyWith(color: p.muted),
              ),
              const SizedBox(height: 22),
              ArtSegmented(
                options: [
                  for (final m in narration.modes)
                    SegmentOption(m.label, detail: m.hint),
                ],
                selected: mode,
                onSelected: ref.read(provider.notifier).setMode,
              ),
              const SizedBox(height: 22),
              GoldLabel(
                'Chapter ${(chapterIndex + 1).toString().padLeft(2, '0')} — '
                '${chapter.title}',
                tracking: .2,
              ),
              const SizedBox(height: 14),
              ListenPlayer(narration: narration),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: AppMotion.medium,
                child: Text(
                  '“${chapter.line}”',
                  key: ValueKey(chapterIndex),
                  style: AppTypography.serif(
                    18,
                    italic: true,
                    height: 1.4,
                  ).copyWith(color: p.ink.withValues(alpha: .82)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
