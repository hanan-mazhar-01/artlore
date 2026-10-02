import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork_content.dart';

/// One chapter set as a magazine spread: headline, opening, pull quote,
/// closing, and the way on to the next chapter.
class StoryChapterView extends StatelessWidget {
  const StoryChapterView({
    super.key,
    required this.chapter,
    required this.next,
    required this.onNext,
  });

  final StoryChapter chapter;
  final StoryChapter next;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final body = AppTypography.body.copyWith(height: 1.7, color: p.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        FadeSlideIn(
          key: ValueKey(chapter.heading),
          child: Semantics(
            header: true,
            child: Text(
              chapter.heading,
              style: AppTypography.serif(
                38,
                weight: FontWeight.w500,
                height: 1.02,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(chapter.opening, style: body),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('“${chapter.quote}”', style: AppTypography.quote),
              const SizedBox(height: 12),
              GoldLabel(chapter.quoteSource, size: 11, tracking: .2),
            ],
          ),
        ),
        Text(chapter.closing, style: body),
        const SizedBox(height: 40),
        Tappable(
          onTap: onNext,
          semanticLabel: 'Next chapter: ${next.label}',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: p.line(.12))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next chapter',
                        style: AppTypography.metadata.copyWith(color: p.muted),
                      ),
                      Text(
                        '${next.label} — ${next.heading}',
                        style: AppTypography.serif(22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ArtIcon(
                  ArtIcons.arrowRight,
                  size: 18,
                  color: p.accent,
                  strokeWidth: 1.5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
