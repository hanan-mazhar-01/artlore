import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../profile/presentation/profile_providers.dart';

/// The visitor's greeting and their avatar — no separate wordmark, no app
/// bar; this one row is the whole top of Home.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final profile = ref.watch(userProfileProvider).value;
    final name = profile?.firstName;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, context.topInset, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorialHeading(
                  lead: name == null ? 'Hi' : 'Hi,',
                  emphasis: name,
                  breakLine: false,
                  style: AppTypography.serif(
                    34,
                    weight: FontWeight.w500,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What will you discover today?',
                  style: AppTypography.bodySmall.copyWith(color: p.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Tappable(
            onTap: () => context.go(AppRoutes.profile),
            semanticLabel: 'Your profile',
            pressedScale: .92,
            // Padding brings the tap target up to the recommended 44dp
            // without enlarging the disc itself.
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: InitialsAvatar(
                initials: profile?.initials ?? '',
                style: AppTypography.sans(12, weight: FontWeight.w600),
                elevated: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
