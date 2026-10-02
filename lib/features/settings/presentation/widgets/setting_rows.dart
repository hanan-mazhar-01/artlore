import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_controls.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';

/// A titled group of setting rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GoldLabel(title),
          ),
          ...rows,
        ],
      ),
    );
  }
}

/// Label + hint on the left, a toggle or a value on the right.
class SettingRow extends StatelessWidget {
  const SettingRow.toggle({
    super.key,
    required this.label,
    required this.hint,
    required bool this.value,
    required this.onTap,
  }) : trailing = null;

  const SettingRow.value({
    super.key,
    required this.label,
    required this.hint,
    required String this.trailing,
    required this.onTap,
  }) : value = null;

  final String label;
  final String hint;
  final bool? value;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isToggle = value != null;
    return Tappable(
      onTap: onTap,
      pressedScale: 1,
      semanticLabel: label,
      child: Semantics(
        toggled: value,
        value: trailing,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.line(.08))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.sans(15)),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: AppTypography.metadata.copyWith(color: p.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isToggle)
                ArtToggle(value: value!)
              else
                Text(
                  trailing!.isEmpty ? '›' : '$trailing ›',
                  style: AppTypography.sans(13).copyWith(color: p.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Free-standing segmented row (Appearance).
class SegmentedSettingRow extends StatelessWidget {
  const SegmentedSettingRow({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String hint;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line(.08))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: AppTypography.sans(15)),
          const SizedBox(height: 2),
          Text(hint, style: AppTypography.metadata.copyWith(color: p.muted)),
          const SizedBox(height: 14),
          ArtSegmented(
            options: [for (final o in options) SegmentOption(o)],
            selected: selected,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}
