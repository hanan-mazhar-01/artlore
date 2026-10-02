import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../theme/app_motion.dart';
import '../theme/app_typography.dart';
import 'tappable.dart';

/// 46×28 toggle — gold when on.
class ArtToggle extends StatelessWidget {
  const ArtToggle({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 46,
      height: 28,
      decoration: BoxDecoration(
        color: value ? p.accent : p.toggleOff,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 350),
        curve: AppMotion.knob,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: p.knob, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// One option of an [ArtSegmented] control.
class SegmentOption {
  const SegmentOption(this.label, {this.detail});

  final String label;
  final String? detail;
}

/// Pill segmented control — Listen's "Quick / Story / Deep Dive" and the
/// Appearance switcher.
class ArtSegmented extends StatelessWidget {
  const ArtSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<SegmentOption> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: p.line(.14)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: Tappable(
                onTap: () => onSelected(i),
                semanticLabel: options[i].label,
                pressedScale: 1,
                child: Semantics(
                  selected: i == selected,
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: i == selected
                          ? p.surface
                          : const Color(0x00000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _SegmentLabel(options[i], i == selected),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.option, this.active);

  final SegmentOption option;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(
          option.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.sans(
            12,
            weight: FontWeight.w600,
          ).copyWith(color: active ? p.accent : p.ink),
        ),
        if (option.detail != null)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              option.detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sans(10).copyWith(color: p.muted),
            ),
          ),
      ],
    );
  }
}
