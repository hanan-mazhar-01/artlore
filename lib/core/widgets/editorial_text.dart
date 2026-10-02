import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';

/// Tracked, uppercase kicker — "FEATURED ARTWORK", "YOUR ART JOURNEY".
class GoldLabel extends StatelessWidget {
  const GoldLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 10,
    this.tracking = .26,
    this.weight = FontWeight.w400,
    this.leadingRule = false,
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final Color? color;
  final double size;
  final double tracking;
  final FontWeight weight;

  /// Prefix an 18pt gold rule — "— IDENTIFIED".
  final bool leadingRule;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.palette.accent;
    final label = Text(
      text.toUpperCase(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: AppTypography.sans(
        size,
        weight: weight,
        tracking: tracking,
      ).copyWith(color: c),
    );
    if (!leadingRule) return label;
    return Row(
      children: [
        Container(width: 18, height: 1, color: c),
        const SizedBox(width: 8),
        Flexible(child: label),
      ],
    );
  }
}

/// Serif heading with an italic, lighter "emphasis" — the design's
/// `Discover<br><em>Art</em>` pattern.
class EditorialHeading extends StatelessWidget {
  const EditorialHeading({
    super.key,
    required this.lead,
    this.emphasis,
    required this.style,
    this.breakLine = true,
    this.color,
    this.textAlign,
  });

  final String lead;
  final String? emphasis;
  final TextStyle style;

  /// Put [emphasis] on its own line (otherwise it flows inline).
  final bool breakLine;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style.copyWith(color: color ?? context.palette.ink);
    final em = emphasis;
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: lead),
            if (em != null)
              TextSpan(
                text: breakLine ? '\n$em' : ' $em',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        textAlign: textAlign,
      ),
    );
  }
}

/// "Continue exploring ……… History" — serif section title with an optional
/// quiet action on the baseline.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.actionColor,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: AppTypography.heading),
          ),
        ),
        if (action != null)
          TextAction(
            label: action!,
            onTap: onAction,
            fontSize: 12,
            color: actionColor,
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
      ],
    );
  }
}

/// 1px hairline rule in the ink colour.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.opacity = .1});

  final double opacity;

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: context.palette.line(opacity));
}
