import '../../legal/open_legal.dart';

import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ambient_motion.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/editorial_text.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/icons/art_icon.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/icons/google_logo.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../history/presentation/history_controller.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../paywall/presentation/premium_controller.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/presentation/settings_controller.dart';

/// The door into the museum: Turner's sunset and three ways in.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _busy = false;
  String? _loadingMessage;

  void _enter() {
    ref.read(settingsProvider.notifier).completeOnboarding();
    context.go(AppRoutes.home);
  }

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
        if (mounted) setState(() => _busy = false);
        return;
      }
      if (mounted) {
        setState(() => _loadingMessage = 'Preparing your gallery…');
      }
      if (wasGuest) {
        await ref
            .read(purchaseRepositoryProvider)
            .grantAccountBonusIfEligible();
      }
    } catch (e) {
      debugPrint('WelcomeScreen signInGoogle error: $e');
      if (mounted) setState(() => _busy = false);
      return;
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
    if (mounted) _enter();
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
        if (mounted) setState(() => _busy = false);
        return;
      }
      if (mounted) {
        setState(() => _loadingMessage = 'Preparing your gallery…');
      }
      if (wasGuest) {
        await ref
            .read(purchaseRepositoryProvider)
            .grantAccountBonusIfEligible();
      }
    } catch (e) {
      debugPrint('WelcomeScreen signInApple error: $e');
      if (mounted) setState(() => _busy = false);
      return;
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
    if (mounted) _enter();
  }

  Future<void> _signInGuest() async {
    setState(() {
      _busy = true;
      _loadingMessage = 'Entering museum…';
    });
    try {
      await ref.read(authServiceProvider).signInAnonymously();
    } catch (_) {}
    await ref.read(historyRepositoryProvider).clearLocalCache();
    await ref.read(collectionRepositoryProvider).clearLocalCache();
    ref.invalidate(recentlyViewedProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(collectionProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(artJourneyProvider);
    PaintingBinding.instance.imageCache.clear();
    try {
      await ref.read(premiumProvider.notifier).refresh();
    } catch (_) {}
    if (mounted) _enter();
  }

  void _goToEmailAuth() => context.push(AppRoutes.emailAuth);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final temeraire = mockCatalog[ArtworkIds.temeraire]!;
    final isDark = context.isDark;

    return ArtScaffold(
      swipeBack: false,
      forceLightStatusBar: isDark,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 520,
            child: DriftImage(temeraire.image),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.ground(.02),
                    p.ground(.35),
                    p.background,
                    p.background,
                  ],
                  stops: const [0.0, 0.28, 0.52, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      32,
                      0,
                      32,
                      math.max(28.0, context.bottomInset + 10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeSlideIn(
                          duration: const Duration(seconds: 1),
                          child: _WelcomeCopy(
                            onEnter: _enter,
                            onGoogle: _signInGoogle,
                            onApple: _signInApple,
                            onGuest: _signInGuest,
                            onEmail: _goToEmailAuth,
                            busy: _busy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy({
    required this.onEnter,
    required this.onGoogle,
    required this.onApple,
    required this.onGuest,
    required this.onEmail,
    this.busy = false,
  });

  final VoidCallback onEnter;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onGuest;
  final VoidCallback onEmail;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? p.accent.withValues(alpha: 0.16)
                    : const Color(0xFFE8DFCD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? p.accent.withValues(alpha: 0.4)
                      : const Color(0xFFB8934E),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? p.accent : const Color(0xFF8B641D),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WELCOME TO ARTLORE',
                    style:
                        AppTypography.sans(
                          11.5,
                          weight: FontWeight.w700,
                          tracking: .22,
                        ).copyWith(
                          color: isDark ? p.accent : const Color(0xFF674812),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EditorialHeading(
          lead: 'Your private',
          emphasis: 'museum companion.',
          style: AppTypography.hero,
        ),
        const SizedBox(height: 14),
        Text(
          'Stand before any painting. We\'ll tell you what it\'s been waiting '
          'to say.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? p.muted : const Color(0xFF4A443C),
          ),
        ),
        const SizedBox(height: 24),
        // On iPhone Sign in with Apple comes first and is as prominent as
        // the other provider.
        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
          PillButton(
            label: 'Continue with Apple',
            onTap: busy ? null : onApple,
            style: PillStyle.inverse,
            leading: ArtIcon(ArtIcons.apple, size: 16, color: p.onInverse),
          ),
          const SizedBox(height: 10),
        ],
        PillButton(
          label: 'Continue with Google',
          onTap: busy ? null : onGoogle,
          style: PillStyle.inverse,
          leading: const GoogleLogo(),
        ),
        const SizedBox(height: 10),
        PillButton(
          label: 'Continue with email',
          onTap: busy ? null : onEmail,
          style: PillStyle.outline,
          leading: ArtIcon(ArtIcons.mail, size: 18, color: p.ink),
          weight: FontWeight.w500,
        ),
        const SizedBox(height: 10),
        Center(
          child: TextAction(
            label: 'Look around first',
            onTap: busy ? null : onGuest,
            padding: const EdgeInsets.all(10),
          ),
        ),
        // Before any account is made, where the rules live.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'By continuing you agree to the ',
                style: AppTypography.caption.copyWith(color: p.muted),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextAction(
              label: 'Terms of Use',
              fontSize: 12,
              onTap: () => openLegal(context, privacy: false),
            ),
            Text(
              ' and ',
              style: AppTypography.caption.copyWith(color: p.muted),
            ),
            TextAction(
              label: 'Privacy Policy',
              fontSize: 12,
              onTap: () => openLegal(context, privacy: true),
            ),
          ],
        ),
      ],
    );
  }
}
