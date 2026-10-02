import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/detective_case.dart';
import 'detective_controller.dart';

/// Guidance while searching; the revelation once found.
class DetectiveFooter extends StatelessWidget {
  const DetectiveFooter({
    super.key,
    required this.detectiveCase,
    required this.state,
    required this.onHint,
    required this.onNext,
    required this.nextLabel,
  });

  final DetectiveCase detectiveCase;
  final DetectiveState state;
  final VoidCallback onHint;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = detectiveCase;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: state.found
          ? FadeSlideIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GoldLabel('Found · ${c.foundTitle}', tracking: .24),
                  const SizedBox(height: 8),
                  Text(
                    c.foundText,
                    style: AppTypography.serif(20, height: 1.35),
                  ),
                  const SizedBox(height: 18),
                  PillButton(
                    label: 'Next case',
                    onTap: onNext,
                    height: 50,
                    fontSize: 14,
                    trailing: Text(
                      nextLabel,
                      style: AppTypography.caption.copyWith(
                        color: p.onInverse.withValues(alpha: .55),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : FadeIn(
              key: ValueKey(state.misses),
              duration: const Duration(milliseconds: 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        c.hintFor(state.misses),
                        style: AppTypography.sans(13).copyWith(color: p.muted),
                      ),
                    ),
                  ),
                  Tappable(
                    onTap: onHint,
                    semanticLabel: 'Show a hint',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: p.accentAlpha(.5)),
                      ),
                      child: Text(
                        'Hint',
                        style: AppTypography.caption.copyWith(color: p.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
