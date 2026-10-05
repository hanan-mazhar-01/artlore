import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/fade_slide_in.dart';

/// Empty walls — an invitation rather than an error.
class CollectionEmpty extends StatelessWidget {
  const CollectionEmpty({
    super.key,
    this.lead = 'Your walls',
    this.emphasis = 'are still bare.',
    this.message =
        'Save a painting from its story and it will hang here, in a '
        'gallery of your own.',
    this.buttonLabel = 'Scan an artwork',
  });

  final String lead;
  final String emphasis;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EditorialHeading(
              lead: lead,
              emphasis: emphasis,
              style: AppTypography.serif(
                34,
                weight: FontWeight.w500,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: p.muted),
            ),
            const SizedBox(height: 26),
            PillButton(
              label: buttonLabel,
              style: PillStyle.outline,
              trailingArrow: true,
              onTap: () => context.push(AppRoutes.scan),
            ),
          ],
        ),
      ),
    );
  }
}
