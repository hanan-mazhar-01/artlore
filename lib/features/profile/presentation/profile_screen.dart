import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../paywall/presentation/premium_controller.dart';
import 'profile_providers.dart';
import 'widgets/profile_widgets.dart';

/// The visitor's room: who they are, how far they've come, where to go.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final journey = ref.watch(artJourneyProvider).value;
    final collection = ref.watch(
      collectionProvider.select((c) {
        final v = c.value;
        return v == null ? null : (v.saved.length, v.galleries.length);
      }),
    );
    final premium = ref.watch(
      premiumProvider.select((s) => s.value?.isPremium ?? false),
    );
    return ArtScaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          context.topInset + 10,
          24,
          AppSpacing.tabBarClearance,
        ),
        children: [
          if (profile != null) ProfileHeader(profile: profile),
          const SizedBox(height: 34),
          if (journey != null) ArtWorldStats(stats: journey.stats),
          const SizedBox(height: 6),
          ProfileRow(
            title: 'My Collection',
            subtitle: collection == null
                ? 'Your galleries'
                : '${collection.$1} works in ${collection.$2} galleries',
            onTap: () => context.go(AppRoutes.collection),
          ),
          ProfileRow(
            title: 'Art Personality',
            subtitle: journey?.personaName ?? 'Your art taste',
            onTap: () => context.push(AppRoutes.personality),
          ),
          ProfileRow(
            title: 'Listening History',
            subtitle: profile == null
                ? 'Stories you heard'
                : '${profile.listeningTime} of stories',
            onTap: () => context.push(AppRoutes.history),
          ),
          ProfileRow(
            title: 'Premium',
            subtitle: premium
                ? 'Active — thank you for supporting ArtLore'
                : 'See beyond the painting',
            highlight: true,
            onTap: () => context.push(AppRoutes.paywall),
          ),
          ProfileRow(
            title: 'Settings',
            subtitle: 'Appearance, narration, privacy, account',
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
