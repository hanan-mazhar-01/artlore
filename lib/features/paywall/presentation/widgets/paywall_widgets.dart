import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/premium_models.dart';

const premiumPerks = [
  'Unlimited artwork scans',
  'Look Closer',
  'AI-narrated stories',
  'Deep Dive',
  'Art Detective',
  'Compare artworks',
  'Personal recommendations',
  'Art Personality',
  'Unlimited collection',
];

/// Two columns of perks, each led by a short gold rule.
class PerksGrid extends StatelessWidget {
  const PerksGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget perk(String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 8, height: 1, color: p.accent),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: AppTypography.sans(12, height: 1.3))),
      ],
    );
    final rows = <Widget>[];
    for (var i = 0; i < premiumPerks.length; i += 2) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 9),
          child: Row(
            children: [
              Expanded(child: perk(premiumPerks[i])),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < premiumPerks.length
                    ? perk(premiumPerks[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// Monthly / Yearly — two halves of one pill.
class PlanSelector extends StatelessWidget {
  const PlanSelector({
    super.key,
    required this.plans,
    required this.selected,
    required this.onSelected,
  });

  final List<SubscriptionPlan> plans;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        for (var i = 0; i < plans.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Tappable(
              onTap: () => onSelected(i),
              semanticLabel:
                  '${plans[i].label}, ${plans[i].price} ${plans[i].period}',
              child: Semantics(
                selected: i == selected,
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: i == selected ? p.accentAlpha(.1) : p.ground(.4),
                    borderRadius: i == 0
                        ? AppRadius.css(22, 4, 4, 22)
                        : AppRadius.css(4, 22, 22, 4),
                    border: Border.all(
                      color: i == selected ? p.accent : p.line(.18),
                    ),
                  ),
                  child: _PlanLabel(plan: plans[i]),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PlanLabel extends StatelessWidget {
  const _PlanLabel({required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final small = AppTypography.metadata.copyWith(color: p.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(plan.label, style: small)),
            if (plan.badge != null)
              Text(plan.badge!, style: small.copyWith(color: p.accent)),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: plan.price, style: AppTypography.serif(24)),
              TextSpan(text: ' ${plan.period}', style: small),
            ],
          ),
        ),
      ],
    );
  }
}

/// The gold call to action.
class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: busy ? .7 : 1,
      child: PillButton(
        label: busy ? 'Opening the gallery…' : label,
        onTap: busy ? null : onTap,
        style: PillStyle.gold,
        height: 56,
        weight: FontWeight.w700,
        trailingArrow: !busy,
      ),
    );
  }
}
