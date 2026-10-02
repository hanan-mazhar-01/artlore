import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../theme/app_motion.dart';
import '../theme/app_typography.dart';
import 'tappable.dart';

/// Underlined text tabs on a hairline (Story chapters, Collection views).
class ArtTabs extends StatelessWidget {
  const ArtTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.gap = 24,
    this.scrollable = false,
    this.padding = EdgeInsets.zero,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final double gap;
  final bool scrollable;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tabs = [
      for (var i = 0; i < labels.length; i++) ...[
        if (i > 0) SizedBox(width: gap),
        _Tab(
          label: labels[i],
          active: i == selected,
          onTap: () => onSelected(i),
        ),
      ],
    ];
    // The hairline is painted inside the child's bounds, so each active
    // underline lands exactly on it (CSS `margin-bottom: -1px`).
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: tabs,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line(.12))),
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: padding,
              child: row,
            )
          : Padding(
              padding: padding,
              child: Align(alignment: Alignment.centerLeft, child: row),
            ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      pressedScale: 1,
      child: Semantics(
        selected: active,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? p.accent : const Color(0x00000000),
              ),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.fast,
            style: AppTypography.sans(
              13,
              weight: FontWeight.w600,
            ).copyWith(color: active ? p.ink : p.muted),
            child: Text(label, maxLines: 1),
          ),
        ),
      ),
    );
  }
}
