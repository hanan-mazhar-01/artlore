import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';

/// "The Story" — a short feather-marked heading over a paragraph that
/// opens with "Read more", so the page stays short until asked otherwise.
class StorySection extends StatefulWidget {
  const StorySection({super.key, required this.summary});

  final String summary;

  @override
  State<StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<StorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ArtIcon(ArtIcons.feather, size: 17, color: p.accent),
            const SizedBox(width: 8),
            Text('The Story', style: AppTypography.heading),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.fast),
          alignment: Alignment.topLeft,
          child: Text(
            widget.summary,
            maxLines: _expanded ? null : 4,
            overflow: _expanded ? null : TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(color: p.muted),
          ),
        ),
        const SizedBox(height: 8),
        Tappable(
          onTap: () => setState(() => _expanded = !_expanded),
          semanticLabel: _expanded ? 'Read less' : 'Read more',
          pressedScale: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: AppTypography.sans(13, weight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? .5 : 0,
                  duration: AppMotion.fast,
                  child: ArtIcon(ArtIcons.chevronDown, size: 15, color: p.ink),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
