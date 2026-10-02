import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/number_words.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork_content.dart';

/// Before the tour: "Four details / worth a second look."
class LookCloserIntro extends StatelessWidget {
  const LookCloserIntro({
    super.key,
    required this.count,
    required this.onBegin,
  });

  final int count;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 48 + context.bottomInset * .3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditorialHeading(
            lead: '${numberWord(count, capitalize: true)} details',
            emphasis: 'worth a second look.',
            style: AppTypography.serif(
              34,
              weight: FontWeight.w500,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap a number to step inside the canvas. Pinch to wander freely.',
            style: AppTypography.sans(13, height: 1.5).copyWith(color: p.muted),
          ),
          const SizedBox(height: 22),
          PillButton(
            label: 'Begin the tour',
            onTap: onBegin,
            height: 52,
            fontSize: 14,
            trailingArrow: true,
          ),
        ],
      ),
    );
  }
}

/// The detail card that rises when a marker is chosen.
class DetailSheet extends StatelessWidget {
  const DetailSheet({
    super.key,
    required this.detail,
    required this.index,
    required this.total,
    required this.onClose,
    required this.onPrevious,
    required this.onNext,
  });

  final ArtworkDetail detail;
  final int index;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(26, 14, 26, 40 + context.bottomInset * .3),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppShadows.sheet(p),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: p.line(.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_two(index + 1)} / ${_two(total)}',
                style: AppTypography.sans(
                  11,
                  tracking: .2,
                ).copyWith(color: p.accent),
              ),
              Tappable(
                onTap: onClose,
                semanticLabel: 'Close detail',
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ArtIcon(ArtIcons.close, size: 16, color: p.muted),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Column(
              key: ValueKey(index),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  detail.title.toUpperCase(),
                  style: AppTypography.serif(
                    30,
                    weight: FontWeight.w500,
                    tracking: .06,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  detail.description,
                  style: AppTypography.serif(
                    19,
                    height: 1.4,
                  ).copyWith(color: p.ink.withValues(alpha: .88)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextAction(
                label: '← Previous',
                onTap: onPrevious,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              ArrowLink(label: 'Next detail', onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}
