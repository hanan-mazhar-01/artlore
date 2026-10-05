import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/tappable.dart';

/// Premium segmented capsule tab bar for Deep Dive chapters (History, Technique, Interpretation).
/// Features a fluid sliding pill indicator with gold accents and tactile haptics.
class DeepDiveTabBar extends StatelessWidget {
  const DeepDiveTabBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = labels.length;
        if (count == 0) return const SizedBox.shrink();
        final totalWidth = constraints.maxWidth;
        const padding = 4.0;
        final trackWidth = totalWidth - (padding * 2);
        final tabWidth = trackWidth / count;
        final pillLeft = padding + (selected * tabWidth);

        return Container(
          height: 46,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: p.line(.16), width: 1),
          ),
          child: Stack(
            children: [
              // Fluid sliding pill indicator
              AnimatedPositioned(
                left: pillLeft,
                top: padding,
                width: tabWidth,
                height: 38,
                duration: const Duration(milliseconds: 320),
                curve: AppMotion.cardCurve,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.background,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: p.accentAlpha(.45),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.shadow.withValues(alpha: p.shadow.a * .4),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels row
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: _DeepDiveTabItem(
                        label: labels[i],
                        index: i,
                        selected: i == selected,
                        onTap: () {
                          Haptics.play(HapticKind.selection);
                          onSelected(i);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeepDiveTabItem extends StatelessWidget {
  const _DeepDiveTabItem({
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  static const _roman = ['I', 'II', 'III', 'IV', 'V'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final numeral = index < _roman.length ? _roman[index] : '${index + 1}';
    return Tappable(
      onTap: onTap,
      semanticLabel: '$numeral. $label',
      pressedScale: 0.96,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          style: AppTypography.sans(
            12,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
          ).copyWith(
            color: selected ? p.ink : p.muted,
            letterSpacing: 0.2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    numeral,
                    style: AppTypography.metadata.copyWith(
                      color:
                          selected ? p.accent : p.muted.withValues(alpha: .7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
