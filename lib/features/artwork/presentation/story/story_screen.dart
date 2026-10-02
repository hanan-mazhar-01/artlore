import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/art_tabs.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/overlap_layout.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';
import 'story_chapter_view.dart';

/// Deep Dive — an editorial publication, chapter by chapter.
class StoryScreen extends ConsumerWidget {
  const StoryScreen({super.key, required this.artworkId});

  final String artworkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artwork = ref.watch(artworkProvider(artworkId)).value;
    final content = ref.watch(artworkContentProvider(artworkId));
    return ArtScaffold(
      forceLightStatusBar: true,
      body: AsyncView(
        value: content,
        data: (c) => artwork == null || c.story.isEmpty
            ? const SizedBox.expand()
            : _StoryBody(artwork: artwork, chapters: c.story),
      ),
    );
  }
}

class _StoryBody extends StatefulWidget {
  const _StoryBody({required this.artwork, required this.chapters});

  final Artwork artwork;
  final List<StoryChapter> chapters;

  @override
  State<_StoryBody> createState() => _StoryBodyState();
}

class _StoryBodyState extends State<_StoryBody> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final chapters = widget.chapters;
    final chapter = chapters[_index];
    final next = chapters[(_index + 1) % chapters.length];
    return SingleChildScrollView(
      child: OverlapLayout(
        backdropHeight: 330,
        overlap: 120,
        backdrop: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<Alignment>(
                tween: AlignmentTween(end: chapter.focus),
                duration: AppMotion.of(context, AppMotion.slow),
                curve: Curves.ease,
                builder: (context, focus, _) => Transform.scale(
                  scale: 1.6,
                  child: ArtImage(
                    widget.artwork.image,
                    alignment: focus,
                    decodeScale: 1.6,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [p.ground(.2), p.background],
                  ),
                ),
              ),
            ],
          ),
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GoldLabel('Deep dive · ${widget.artwork.title}'),
              const SizedBox(height: 20),
              ArtTabs(
                labels: [for (final c in chapters) c.label],
                selected: _index,
                scrollable: true,
                onSelected: (i) => setState(() => _index = i),
              ),
              StoryChapterView(
                chapter: chapter,
                next: next,
                onNext: () =>
                    setState(() => _index = (_index + 1) % chapters.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
