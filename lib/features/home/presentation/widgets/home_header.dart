import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../profile/presentation/profile_providers.dart';

/// Wordmark and avatar — no app bar, just the gallery's name.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = ref.watch(
      userProfileProvider.select((v) => v.value?.initials ?? ''),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(24, context.topInset, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ArtLore',
            style: AppTypography.serif(22, weight: FontWeight.w500),
          ),
          Tappable(
            onTap: () => context.go(AppRoutes.profile),
            semanticLabel: 'Your profile',
            child: InitialsAvatar(
              initials: initials,
              style: AppTypography.sans(12, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
