import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/art_toast.dart';
import '../../artwork/data/dynamic_artwork_storage.dart';
import '../../collections/presentation/collection_controller.dart';

import '../../history/presentation/history_controller.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../paywall/presentation/premium_controller.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../scan/presentation/ai_consent.dart';
import '../../wall/wall_controller.dart';
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
        final v = c.asData?.value ?? c.value;
        return v == null ? null : (v.saved.length, v.galleries.length);
      }),
    );
    final premiumStatus = ref.watch(
      premiumProvider.select((s) => s.asData?.value ?? s.value),
    );
    final premium = premiumStatus?.isPremium ?? false;
    final isTrial = premiumStatus?.isTrial ?? false;
    final planId = premiumStatus?.planId?.toLowerCase();
    final freeScans = premiumStatus?.freeScansLeft ?? 0;
    final planLabel = planId == null
        ? null
        : (planId.contains('yearly') || planId.contains('annual')
              ? 'Yearly Plan'
              : (planId.contains('monthly') ? 'Monthly Plan' : null));

    final String statusLabel;
    if (premium) {
      if (isTrial) {
        statusLabel = 'Trial Active';
      } else if (planId != null &&
          (planId.contains('yearly') || planId.contains('annual'))) {
        statusLabel = 'Yearly Subscription Active';
      } else if (planId != null && planId.contains('monthly')) {
        statusLabel = 'Monthly Subscription Active';
      } else {
        statusLabel = 'Subscription Active';
      }
    } else {
      statusLabel = '$freeScans ${freeScans == 1 ? 'scan' : 'scans'} left';
    }

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
              subscriptionLabel: statusLabel,
              isPremium: premium,
            ),
          const SizedBox(height: 34),
          if (journey != null) ArtWorldStats(stats: journey.stats),
          const SizedBox(height: 6),
          ProfileRow(
            title: 'My Collection',
            subtitle: (collection == null || collection.$1 == 0)
                ? 'No saved artworks yet'
                : '${collection.$1} ${collection.$1 == 1 ? 'work' : 'works'} in ${collection.$2} ${collection.$2 == 1 ? 'gallery' : 'galleries'}',
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
                ? (isTrial
                      ? 'Free Trial · Active'
                      : (planLabel != null
                            ? '$planLabel · Active'
                            : 'Active — thank you for supporting ArtLore'))
                : 'See beyond the painting',
            highlight: true,
            onTap: () => context.push(AppRoutes.paywall),
          ),
          ProfileRow(
            title: 'Settings',
            subtitle: 'Appearance, privacy, preferences',
            onTap: () => context.push(AppRoutes.settings),
          ),
          // A guest has no account to sign out of or delete: they are offered
          // one instead.
          if (ref.watch(isGuestProvider).value ??
              (ref.read(authServiceProvider).currentUser?.isAnonymous ?? false))
            ProfileRow(
              title: 'Sign in to save',
              subtitle: 'Create an account to keep your collection',
              highlight: true,
              onTap: () async {
                final done = await context.push<bool>(
                  AppRoutes.accountWall,
                  extra: 'save',
                );
                if (done == true) ref.invalidate(userProfileProvider);
              },
            )
          else ...[
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.line(.1)),
        ),
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
              await ref.read(historyRepositoryProvider).clearLocalCache();
              await ref.read(collectionRepositoryProvider).clearLocalCache();
              await ref.read(recentlyViewedProvider.notifier).clear();
              PaintingBinding.instance.imageCache.clear();
              ref.invalidate(premiumProvider);
              ref.invalidate(collectionProvider);
              ref.invalidate(historyProvider);
              ref.invalidate(userProfileProvider);
              ref.invalidate(recentlyViewedProvider);
              ref.invalidate(artJourneyProvider);
              ref.read(settingsProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: Text('Sign Out', style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (confirmed != true || !context.mounted) return;

    final p = context.palette;

    // Show non-dismissible loading indicator
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (loadingCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: p.line(.1)),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: p.accent,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    'Deleting account…',
                    style: AppTypography.sans(
                      14,
                      weight: FontWeight.w500,
                    ).copyWith(color: p.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await ref.read(userProfileProvider.notifier).deleteAccount();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      // Tell the visitor, and keep them signed in: the account still exists.
      if (context.mounted) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        ArtToast.show(
          context,
          "We couldn't finish deleting your account. Please sign in again "
          'when asked, and try once more.',
        );
      }
      return;
    }

    try {
      await ref.read(authServiceProvider).signOut();
    } catch (_) {}
    await ref.read(historyRepositoryProvider).clearLocalCache();
    await ref.read(collectionRepositoryProvider).clearLocalCache();
    await ref.read(recentlyViewedProvider.notifier).clear();
    await DynamicArtworkStorage.clearAll();
    PaintingBinding.instance.imageCache.clear();

    // Everything else the app remembered on this phone — the wall, the AI
    // agreement, the settings, the theme — goes too, so a new account starts
    // as a first visit. Only the device id stays: it guards the free scans.
    final prefs = ref.read(sharedPreferencesProvider);
    for (final key in prefs.getKeys().toList()) {
      if (!key.startsWith('artlore.') || key == 'artlore.device_id') continue;
      await prefs.remove(key);
    }
    ref.invalidate(wallProvider);
    ref.invalidate(aiConsentProvider);
    ref.invalidate(settingsProvider);

    ref.invalidate(premiumProvider);
    ref.invalidate(collectionProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(recentlyViewedProvider);
    ref.invalidate(artJourneyProvider);
    ref.read(settingsProvider.notifier).signOut();

    if (context.mounted) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      context.go(AppRoutes.welcome);
    }
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _controller;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    final matches = val.trim().toLowerCase() == 'delete';
    if (_isConfirmed != matches) {
      setState(() => _isConfirmed = matches);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.line(.1)),
      ),
      title: Text(
        'Delete Account',
        style: AppTypography.serif(22).copyWith(color: p.danger),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete your profile, saved collections, and exploration history. This action cannot be undone.',
              style: AppTypography.sans(
                14,
                height: 1.4,
              ).copyWith(color: p.muted),
            ),
            const SizedBox(height: 18),
            Text(
              'To confirm, type "delete" below:',
              style: AppTypography.sans(
                13,
                weight: FontWeight.w600,
              ).copyWith(color: p.ink),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              style: AppTypography.sans(14).copyWith(color: p.ink),
              decoration: InputDecoration(
                hintText: 'delete',
                hintStyle: AppTypography.sans(14)
                    .copyWith(color: p.muted.withValues(alpha: 0.5)),
                filled: true,
                fillColor: p.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: p.line(.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isConfirmed ? p.danger : p.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: p.muted)),
        ),
        TextButton(
          onPressed: _isConfirmed
              ? () => Navigator.of(context).pop(true)
              : null,
          child: Text(
            'Delete Account',
            style: TextStyle(
              color: _isConfirmed ? p.danger : p.muted.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}
