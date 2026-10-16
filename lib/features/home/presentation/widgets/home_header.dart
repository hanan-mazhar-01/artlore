import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../profile/presentation/profile_providers.dart';
import 'home_style.dart';

/// "Hi, Name" over a one-line tagline, and the search button and profile avatar on the right.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = HomeStyle.of(context);
    final profile = ref.watch(userProfileProvider).value;
    final firstName = _firstName(profile);
    return Padding(
      padding: EdgeInsets.fromLTRB(22, context.topInset, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName == null ? 'Hi' : 'Hi, $firstName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.serif(
                        34,
                        weight: FontWeight.w700,
                        height: 1.05,
                        tracking: -.01,
                      ).copyWith(color: s.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tappable(
                onTap: () => context.push(AppRoutes.search),
                semanticLabel: 'Search',
                pressedScale: .92,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.surface,
                  ),
                  child: ArtIcon(ArtIcons.search, size: 19, color: s.ink),
                ),
              ),
              const SizedBox(width: 10),
              Tappable(
                onTap: () => context.go(AppRoutes.profile),
                semanticLabel: 'Your profile',
                pressedScale: .92,
                child: InitialsAvatar(
                  initials: profile?.initials ?? '',
                  imageUrl: profile?.photoUrl,
                  size: 46,
                  style: AppTypography.sans(18, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text.rich(
              TextSpan(
                style: AppTypography.serif(
                  32,
                  weight: FontWeight.w700,
                  height: 1.04,
                ).copyWith(color: s.ink),
                children: [
                  const TextSpan(text: 'Every Painting Has a '),
                  TextSpan(
                    text: 'Story',
                    style: TextStyle(color: s.gold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              'Scan a masterpiece and uncover the story behind every '
              'brushstroke.',
              style: AppTypography.sans(
                13.5,
                weight: FontWeight.w500,
                height: 1.45,
              ).copyWith(color: s.muted),
            ),
          ),
        ],
      ),
    );
  }

  String? _firstName(dynamic profile) {
    if (profile == null) return null;
    final String raw = profile.firstName?.trim() ?? '';
    if (raw.isEmpty ||
        raw == 'Visitor' ||
        raw == 'Art Visitor' ||
        raw == 'Guest Collector') {
      return null;
    }
    final words = raw.split(RegExp(r'\s+'));
    final first = words.first.trim();
    return first.isEmpty ? null : first;
  }
}
