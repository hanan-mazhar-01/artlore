import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';

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
                duration: AppMotion.medium,
                height: 2,
                color: i <= current ? p.accent : p.line(.16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
