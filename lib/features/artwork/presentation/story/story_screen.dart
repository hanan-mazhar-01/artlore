import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/overlap_layout.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import '../artwork_providers.dart';
import 'deep_dive_tab_bar.dart';
import 'story_chapter_view.dart';

/// Deep Dive — an editorial publication, chapter by chapter.
/// Presented with a full-bleed parallax artwork backdrop, a rounded sheet
/// with ambient glow, and animated capsule tabs for History, Technique, and Interpretation.
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
  final _scroll = ScrollController();
  int _index = 0;

  void _selectChapter(int newIndex) {
    if (newIndex == _index) return;
    setState(() => _index = newIndex);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final chapters = widget.chapters;
    final chapter = chapters[_index];
    final next = chapters[(_index + 1) % chapters.length];

    return SingleChildScrollView(
      controller: _scroll,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ambient blurred glow behind the sheet
          Positioned(
            left: -60,
            top: 360,
            width: 520,
            height: 900,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: Opacity(
                  opacity: .12,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                    child: ArtImage(widget.artwork.image, decodeScale: .25),
                  ),
                ),
              ),
            ),
          ),

          // Main overlap layout: majestic backdrop + rising rounded sheet
          OverlapLayout(
            backdropHeight: 440,
            overlap: 40,
            backdrop: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _scroll,
                    builder: (context, child) {
                      final offset = _scroll.hasClients ? _scroll.offset : 0.0;
                      return Transform.translate(
                        offset: Offset(0, offset > 0 ? offset * .35 : 0),
                        child: Transform.scale(
                          scale: offset < 0 ? 1 - offset / 600 : 1,
                          alignment: Alignment.topCenter,
                          child: child,
                        ),
                      );
                    },
                    child: TweenAnimationBuilder<Alignment>(
                      tween: AlignmentTween(end: chapter.focus),
                      duration: AppMotion.of(
                        context,
                        const Duration(milliseconds: 900),
                      ),
                      curve: AppMotion.reveal,
                      builder: (context, focus, _) => Transform.scale(
                        scale: 1.45,
                        child: ArtImage(
                          widget.artwork.image,
                          alignment: focus,
                          decodeScale: 1.5,
                          semanticLabel: widget.artwork.semanticLabel,
                        ),
                      ),
                    ),
                  ),
                  // Dark vignette for crystal-clear glass back button legibility
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 130,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Color(0x00000000)],
                        ),
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
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassIconButton(
                      icon: ArtIcons.chevronLeft,
                      onTap: () => context.backOr(),
                      semanticLabel: 'Back',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x3D000000),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x33FFFFFF),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_index + 1} / ${chapters.length}',
                        style: AppTypography.metadata.copyWith(
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Rounded sheet rising over the painting
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
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: p.line(.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Deep Dive Header
                    GoldLabel(
                      'DEEP DIVE · ${widget.artwork.title.toUpperCase()}',
                      tracking: .24,
                    ),
                    const SizedBox(height: 18),

                    // Fully animated capsule segmented tabs
                    DeepDiveTabBar(
                      labels: [for (final c in chapters) c.label],
                      selected: _index,
                      onSelected: _selectChapter,
                    ),

                    // Chapter content swaps instantly — no transition.
                    StoryChapterView(
                      chapter: chapter,
                      index: _index,
                      total: chapters.length,
                      next: next,
                      onNext: () =>
                          _selectChapter((_index + 1) % chapters.length),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
