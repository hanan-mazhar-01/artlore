import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../theme/app_typography.dart';
import '../utils/haptics.dart';
import 'icons/art_icon.dart';
import 'icons/art_icons.dart';
import 'tappable.dart';

enum PillStyle { inverse, outline, gold }

/// The design's pill buttons.
///
/// * [PillStyle.inverse] — ivory pill (charcoal in light mode). Primary.
/// * [PillStyle.outline] — hairline outline. Secondary.
/// * [PillStyle.gold] — the premium call to action.
///
/// With [trailingArrow] the label sits flush left and the arrow right, as in
/// "Begin the tour"; otherwise content is centred.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style = PillStyle.inverse,
    this.height = 54,
    this.leading,
    this.trailingArrow = false,
    this.trailing,
    this.fontSize = 15,
    this.weight = FontWeight.w600,
    this.haptic = HapticKind.light,
  });

  final String label;
  final VoidCallback? onTap;
  final PillStyle style;
  final double height;
  final Widget? leading;
  final bool trailingArrow;
  final Widget? trailing;
  final double fontSize;
  final FontWeight weight;
  final HapticKind haptic;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg, border) = switch (style) {
      PillStyle.inverse => (p.inverse, p.onInverse, null),
      PillStyle.gold => (p.accent, p.onAccent, null),
      PillStyle.outline => (null, p.ink, p.line(.22)),
    };
    final text = Text(
      label,
      style: AppTypography.sans(fontSize, weight: weight).copyWith(color: fg),
    );
    final spread = trailingArrow || trailing != null;
    return Tappable(
      onTap: onTap,
      haptic: haptic,
      semanticLabel: label,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: spread ? 22 : 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(height / 2),
          border: border == null ? null : Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: spread
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Flexible(child: text),
            ?trailing,
            if (trailingArrow)
              ArtIcon(
                ArtIcons.arrowRight,
                size: 16,
                color: fg,
                strokeWidth: 1.8,
              ),
          ],
        ),
      ),
    );
  }
}

/// Inline gold call to action — "Explore story →", "Next detail →".
class ArrowLink extends StatelessWidget {
  const ArrowLink({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.palette.accent;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.sans(
            fontSize,
            weight: FontWeight.w600,
          ).copyWith(color: c),
        ),
        const SizedBox(width: 8),
        ArtIcon(ArtIcons.arrowRight, size: 14, color: c, strokeWidth: 1.8),
      ],
    );
    if (onTap == null) return row;
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: row,
      ),
    );
  }
}

/// Plain text action — "Skip", "History", "Restore".
class TextAction extends StatelessWidget {
  const TextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      child: Padding(
        padding: padding,
        child: Text(
          label,
          style: AppTypography.sans(fontSize)
              .copyWith(color: color ?? context.palette.muted),
        ),
      ),
    );
  }
}
