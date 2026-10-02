import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../artwork/data/mock_catalog.dart';
import '../../settings/presentation/settings_controller.dart';

/// The door into the museum: Turner's sunset and three ways in.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final temeraire = mockCatalog[ArtworkIds.temeraire]!;
    void enter() {
      ref.read(settingsProvider.notifier).completeOnboarding();
      context.go(AppRoutes.home);
    }

    return ArtScaffold(
      swipeBack: false,
      forceLightStatusBar: true,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 560,
            child: DriftImage(temeraire.image),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.ground(.1), p.ground(.3), p.background],
                  stops: const [0, .4, .68],
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
                          child: _WelcomeCopy(onEnter: enter),
                        ),
                      ],
                    ),
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
  const _WelcomeCopy({required this.onEnter});

  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GoldLabel('Welcome to ArtLore', tracking: .28),
        const SizedBox(height: 14),
        EditorialHeading(
          lead: 'Your private',
          emphasis: 'museum companion.',
          style: AppTypography.hero,
        ),
        const SizedBox(height: 14),
        Text(
          'Stand before any painting. We\'ll tell you what it\'s been waiting '
          'to say.',
          style: AppTypography.bodySmall.copyWith(color: p.muted),
        ),
        const SizedBox(height: 28),
        PillButton(
          label: 'Continue with Apple',
          onTap: onEnter,
          leading: ArtIcon(ArtIcons.apple, size: 16, color: p.onInverse),
        ),
        const SizedBox(height: 10),
        PillButton(
          label: 'Continue with email',
          onTap: onEnter,
          style: PillStyle.outline,
          weight: FontWeight.w500,
        ),
        const SizedBox(height: 10),
        Center(
          child: TextAction(
            label: 'Look around first',
            onTap: onEnter,
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}
