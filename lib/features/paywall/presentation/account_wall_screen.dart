import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/editorial_text.dart';
import '../../../core/widgets/icons/art_icon.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/icons/google_logo.dart';
import '../../../core/widgets/round_buttons.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../history/presentation/history_controller.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'premium_controller.dart';

/// Shown when a guest has used their free scans — asks them to create an
/// account or sign in before continuing, before the paywall ever appears.
/// Pops `true` on success so the caller can resume the scan.
class AccountWallScreen extends ConsumerStatefulWidget {
  const AccountWallScreen({super.key});

  @override
  ConsumerState<AccountWallScreen> createState() => _AccountWallScreenState();
}

class _AccountWallScreenState extends ConsumerState<AccountWallScreen> {
  bool _busy = false;
  String? _loadingMessage;

  Future<void> _signInGoogle() async {
    setState(() {
      _busy = true;
      _loadingMessage = 'Connecting to Google…';
    });
    final wasGuest =
        ref.read(authServiceProvider).currentUser?.isAnonymous ?? false;
    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();
      if (cred == null) {
        if (mounted) {
          setState(() {
            _busy = false;
            _loadingMessage = null;
          });
        }
        return;
      }
      if (mounted) {
        setState(() => _loadingMessage = 'Updating your account…');
      }
      if (wasGuest) {
        await ref
            .read(purchaseRepositoryProvider)
            .grantAccountBonusIfEligible();
      }
      await ref.read(historyRepositoryProvider).clearLocalCache();
      await ref.read(collectionRepositoryProvider).clearLocalCache();
      ref.invalidate(recentlyViewedProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(collectionProvider);
      ref.invalidate(historyProvider);
      ref.invalidate(artJourneyProvider);
      PaintingBinding.instance.imageCache.clear();
      await ref.read(premiumProvider.notifier).refresh();
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _signInApple() async {
    setState(() {
      _busy = true;
      _loadingMessage = 'Connecting to Apple…';
    });
    final wasGuest =
        ref.read(authServiceProvider).currentUser?.isAnonymous ?? false;
    try {
      final cred = await ref.read(authServiceProvider).signInWithApple();
      if (cred == null) {
        if (mounted) {
          setState(() {
            _busy = false;
            _loadingMessage = null;
          });
        }
        return;
      }
      if (mounted) {
        setState(() => _loadingMessage = 'Updating your account…');
      }
      if (wasGuest) {
        await ref
            .read(purchaseRepositoryProvider)
            .grantAccountBonusIfEligible();
      }
      await ref.read(historyRepositoryProvider).clearLocalCache();
      await ref.read(collectionRepositoryProvider).clearLocalCache();
      ref.invalidate(recentlyViewedProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(collectionProvider);
      ref.invalidate(historyProvider);
      ref.invalidate(artJourneyProvider);
      PaintingBinding.instance.imageCache.clear();
      await ref.read(premiumProvider.notifier).refresh();
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _goToEmailAuth() async {
    final ok = await context.push<bool>(AppRoutes.emailAuth);
    if (ok == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = context.isDark;
    return ArtScaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlineIconButton(
                    onTap: () => _busy ? null : context.pop(false),
                  ),
                  const SizedBox(height: 28),
                  const GoldLabel('Free scans used', tracking: .28),
                  const SizedBox(height: 14),
                  EditorialHeading(
                    lead: 'Create an account',
                    emphasis: 'to keep exploring.',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You\'ve used your free scans as a guest. Sign up — it\'s '
                    'free — and we\'ll give you a few more.',
                    style: AppTypography.bodySmall.copyWith(color: p.muted),
                  ),
                  const SizedBox(height: 28),
                  PillButton(
                    label: 'Continue with Google',
                    onTap: _busy ? null : _signInGoogle,
                    style: PillStyle.inverse,
                    leading: const GoogleLogo(),
                    loading:
                        _busy && _loadingMessage?.contains('Google') == true,
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                    const SizedBox(height: 10),
                    PillButton(
                      label: 'Continue with Apple',
                      onTap: _busy ? null : _signInApple,
                      style: PillStyle.outline,
                      leading: ArtIcon(ArtIcons.apple, size: 16, color: p.ink),
                      loading:
                          _busy && _loadingMessage?.contains('Apple') == true,
                    ),
                  ],
                  const SizedBox(height: 10),
                  PillButton(
                    label: 'Continue with email',
                    onTap: _busy ? null : _goToEmailAuth,
                    style: PillStyle.outline,
                    leading: ArtIcon(ArtIcons.mail, size: 18, color: p.ink),
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
          if (_busy)
            Positioned.fill(
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.65,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.line(.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: p.accent,
                          ),
                        ),
                        if (_loadingMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _loadingMessage!,
                            style: AppTypography.sans(
                              14,
                              weight: FontWeight.w500,
                            ).copyWith(color: p.ink),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
