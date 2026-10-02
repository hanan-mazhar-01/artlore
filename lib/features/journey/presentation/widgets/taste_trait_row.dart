import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/art_journey.dart';

/// A taste axis with its percentage and a bar that draws itself in.
class TasteTraitRow extends StatelessWidget {
  const TasteTraitRow({super.key, required this.trait, required this.rank});

  final TasteTrait trait;

  /// 0 is the strongest trait (gold), the last fades to muted.
  final int rank;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = rank == 0 ? p.accent : (rank < 3 ? p.ink : p.muted);
    final fraction = trait.value / 100;
    return Semantics(
      label: '${trait.label}, ${trait.value} percent',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line(.1))),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(trait.label, style: AppTypography.serif(24)),
                ),
                Text(
                  '${trait.value}%',
                  style: AppTypography.serif(
                    26,
                    italic: true,
                  ).copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 2,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: .5,
                    height: 1,
                    child: ColoredBox(color: p.line(.12)),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: AppMotion.of(
                      context,
                      const Duration(milliseconds: 1400),
                    ),
                    curve: AppMotion.reveal,
                    builder: (context, f, _) => FractionallySizedBox(
                      widthFactor: f,
                      child: ColoredBox(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
