import '../../legal/open_legal.dart';

import 'dart:math' as math;

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ambient_motion.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/art_toast.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/editorial_text.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/round_buttons.dart';
import '../../artwork/data/mock_catalog.dart';
import 'premium_controller.dart';
import 'widgets/paywall_widgets.dart';

/// "See beyond the painting." — ArtLore Premium.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _plan = 1;
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action, String success) async {
    setState(() => _busy = true);
    var ok = false;
    String? failure;
    try {
      ok = await action();
    } on PlatformException catch (e) {
      // Backing out of Apple's purchase sheet is not an error: say nothing.
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        failure = code == PurchasesErrorCode.paymentPendingError
            ? 'Your purchase is pending approval.'
            : "The purchase couldn't be completed. Please try again.";
      }
      if (!mounted) return;
      setState(() => _busy = false);
      if (failure != null) ArtToast.show(context, failure);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ArtToast.show(
        context,
        "Something went wrong. Please check your connection and try again.",
      );
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ArtToast.show(context, ok ? success : 'No previous purchase found');
    if (ok) context.go(AppRoutes.home);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final plans = ref.watch(plansProvider).value ?? const [];
    final isPremium = ref.watch(
      premiumProvider.select((s) => s.value?.isPremium ?? false),
    );
    final premium = ref.read(premiumProvider.notifier);
    final plan = plans.isEmpty ? null : plans[_plan.clamp(0, plans.length - 1)];
    final wanderer = mockCatalog[ArtworkIds.wanderer]!;
    final note = AppTypography.sans(13, height: 1.35).copyWith(color: p.muted);
    return ArtScaffold(
      forceLightStatusBar: true,
      body: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: c.maxHeight * .68,
              child: DriftImage(
                wanderer.image,
                period: const Duration(seconds: 20),
                alignment: const Alignment(0, -.4),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [p.ground(.25), p.ground(.55), p.background],
                    stops: const [0, .3, .58],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      26,
                      context.topInset + 60,
                      26,
                      math.max(28.0, context.bottomInset + 4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const GoldLabel('ArtLore Premium', tracking: .3),
                        const SizedBox(height: 12),
                        EditorialHeading(
                          lead: 'See beyond',
                          emphasis: 'the painting.',
                          style: AppTypography.serif(
                            48,
                            weight: FontWeight.w500,
                            height: .96,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Unlock the full ArtLore experience.',
                          style: AppTypography.bodySmall.copyWith(
                            color: p.muted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const PerksGrid(),
                        const SizedBox(height: 22),
                        if (plans.isNotEmpty)
                          PlanSelector(
                            plans: plans,
                            selected: _plan,
                            onSelected: (i) => setState(() => _plan = i),
                          ),
                        const SizedBox(height: 14),
                        PremiumButton(
                          label: isPremium
                              ? 'Manage Subscription'
                              : plan == null
                              ? 'Try again'
                              : (plan.hasTrial && plan.trialDays > 0)
                              ? 'Begin ${plan.trialDays} days free'
                              : 'Subscribe · ${plan.price}${plan.period}',
                          busy: _busy,
                          onTap: isPremium
                              ? () => _openUrl(
                                  'https://apps.apple.com/account/subscriptions',
                                )
                              : (plan == null
                                    ? () => ref.invalidate(plansProvider)
                                    : () => _run(
                                        () => premium.purchase(plan.id),
                                        'Welcome to ArtLore Premium',
                                      )),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                plan?.renewalNote ??
                                    (ref.watch(plansProvider).isLoading
                                        ? 'Loading plans…'
                                        : "Plans can't be loaded right now."),
                                style: note,
                              ),
                            ),
                            TextAction(
                              label: 'Restore',
                              fontSize: 13,
                              onTap: _busy
                                  ? null
                                  : () => _run(
                                      premium.restore,
                                      'Your membership is restored',
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // The standard auto-renewal terms, stated before the
                        // purchase.
                        Text(
                          'Payment is charged to your Apple ID at confirmation '
                          'of purchase. The subscription renews automatically '
                          'unless it is cancelled at least 24 hours before the '
                          'end of the current period. Any unused part of a free '
                          'trial is forfeited when you subscribe. Manage or '
                          'cancel anytime in your App Store account settings.',
                          textAlign: TextAlign.center,
                          style: note.copyWith(fontSize: 11, height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextAction(
                              label: 'Terms of Use',
                              fontSize: 13,
                              onTap: () => openLegal(context, privacy: false),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text('•', style: note),
                            ),
                            TextAction(
                              label: 'Privacy Policy',
                              fontSize: 13,
                              onTap: () => openLegal(context, privacy: true),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: context.topInset,
              right: 20,
              child: GlassIconButton(
                icon: ArtIcons.close,
                size: 40,
                iconSize: 16,
                bordered: false,
                onTap: () => context.backOr(),
                semanticLabel: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
