import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../paywall/presentation/premium_controller.dart';
import '../../settings/presentation/settings_controller.dart';
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
          if (profile != null)
            ProfileHeader(
              profile: profile,
              onEdit: () => _editName(context, ref, profile.name),
            ),
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
            title: 'Scan History',
            subtitle: 'Past scans and artworks explored',
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
            subtitle: 'Appearance, privacy, preferences',
            onTap: () => context.push(AppRoutes.settings),
          ),
          ProfileRow(
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _confirmSignOut(context, ref),
          ),
          ProfileRow(
            title: 'Delete Account',
            subtitle: 'Permanently remove your profile and collection',
            danger: true,
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    final p = context.palette;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text('Edit Name', style: AppTypography.serif(22)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.sans(15).copyWith(color: p.ink),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTypography.sans(15).copyWith(color: p.muted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: p.line(.2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: p.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: p.muted)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(userProfileProvider.notifier).updateName(newName);
              }
              Navigator.of(ctx).pop();
            },
            child: Text('Save', style: TextStyle(color: p.accent)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text('Sign Out', style: AppTypography.serif(22)),
        content: Text(
          'Are you sure you want to sign out of ArtLore?',
          style: AppTypography.sans(14).copyWith(color: p.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: p.muted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(authServiceProvider).signOut();
              } catch (_) {}
              ref.invalidate(premiumProvider);
              ref.read(settingsProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: Text('Sign Out', style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(
          'Delete Account',
          style: AppTypography.serif(22).copyWith(color: p.danger),
        ),
        content: Text(
          'This will permanently delete your profile, saved collections, and exploration history. This action cannot be undone.',
          style: AppTypography.sans(14, height: 1.4).copyWith(color: p.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: p.muted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(userProfileProvider.notifier).deleteAccount();
              } catch (_) {}
              try {
                await ref.read(authServiceProvider).signOut();
              } catch (_) {}
              ref.invalidate(premiumProvider);
              ref.read(settingsProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            child: Text('Delete Account', style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
  }
}
