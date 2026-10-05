import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';

/// Thin gold bars that fill as the visitor moves through arrival.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: 'Page ${current + 1} of $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                height: i == current ? 2.5 : 2.0,
                decoration: BoxDecoration(
                  color: i <= current ? p.accent : p.line(.18),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: i == current
                      ? [
                          BoxShadow(
                            color: p.accentAlpha(.4),
                            blurRadius: 6,
                            spreadRadius: .5,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
