import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork_content.dart';

/// One chapter set as an editorial museum spread: headline, opening narrative,
/// luxury pull quote card, closing insight, and interactive next chapter card.
class StoryChapterView extends StatelessWidget {
  const StoryChapterView({
    super.key,
    required this.chapter,
    required this.next,
    required this.onNext,
    this.index = 0,
    this.total = 3,
  });

  final StoryChapter chapter;
  final StoryChapter next;
  final VoidCallback onNext;
  final int index;
  final int total;

  static const _roman = ['I', 'II', 'III', 'IV', 'V'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isLast = index >= total - 1;
    final numeral = index < _roman.length ? _roman[index] : '${index + 1}';
    final body = AppTypography.body.copyWith(
      height: 1.75,
      fontSize: 16,
      color: p.ink.withValues(alpha: .88),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),

        // Chapter kicker & headline
        GoldLabel(
          'CHAPTER $numeral · ${chapter.label.toUpperCase()}',
          tracking: .22,
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            chapter.heading,
            style: AppTypography.serif(
              34,
              weight: FontWeight.w500,
              height: 1.06,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Opening paragraph
        Text(chapter.opening, style: body),
        const SizedBox(height: 28),

        // Luxury Editorial Pull Quote Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.accentAlpha(.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: p.shadow.withValues(alpha: p.shadow.a * .25),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3.5,
                height: 58,
                margin: const EdgeInsets.only(top: 4, right: 16),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${chapter.quote}”',
                      style: AppTypography.serif(
                        18,
                        italic: true,
                        height: 1.45,
                      ).copyWith(color: p.ink),
                    ),
                    const SizedBox(height: 12),
                    GoldLabel(chapter.quoteSource, size: 11, tracking: .18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Closing takeaway
        Text(chapter.closing, style: body),
        const SizedBox(height: 38),

        // Next Chapter Interactive Card
        Tappable(
          onTap: () {
            Haptics.play(HapticKind.light);
            onNext();
          },
          semanticLabel: isLast
              ? 'Return to first chapter: ${next.label}'
              : 'Next chapter: ${next.label}',
          pressedScale: 0.98,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line(.14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GoldLabel(
                        isLast ? 'COMPLETE · RESTART' : 'NEXT CHAPTER',
                        size: 10,
                        tracking: .22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${next.label} — ${next.heading}',
                        style: AppTypography.serif(18, height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.accentAlpha(.15),
                    border: Border.all(color: p.accentAlpha(.35)),
                  ),
                  child: ArtIcon(
                    isLast ? ArtIcons.check : ArtIcons.arrowRight,
                    size: 16,
                    color: p.accent,
                    strokeWidth: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
