import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    ArtToast.show(context, ok ? success : 'No previous purchase found');
    if (ok) context.go(AppRoutes.home);
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
    final note = AppTypography.metadata.copyWith(color: p.muted);
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
                              ? 'You\'re a member — explore'
                              : 'Begin 7 days free',
                          busy: _busy,
                          onTap: isPremium || plan == null
                              ? () => context.go(AppRoutes.home)
                              : () => _run(
                                  () => premium.purchase(plan.id),
                                  'Welcome to ArtLore Premium',
                                ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(plan?.renewalNote ?? '', style: note),
                            ),
                            TextAction(
                              label: 'Restore',
                              fontSize: 11,
                              onTap: _busy
                                  ? null
                                  : () => _run(
                                      premium.restore,
                                      'Your membership is restored',
                                    ),
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
