import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/icons/art_icon.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/tappable.dart';
import '../domain/onboarding_slide.dart';
import 'widgets/onboarding_collages.dart';
import 'widgets/onboarding_progress.dart';

/// Four cinematic pages: art above, an editorial line below.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  void _next() {
    if (_index < onboardingSlides.length - 1) {
      setState(() => _index++);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  void _previous() {
    if (_index > 0) {
      Haptics.play(HapticKind.selection);
      setState(() => _index--);
    }
  }

  void _onSwipe(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -250) {
      Haptics.play(HapticKind.selection);
      _next();
    } else if (v > 250) {
      _previous();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final slide = onboardingSlides[_index];
    final bottomPad = math.max(28.0, context.bottomInset + 10);
    return ArtScaffold(
      swipeBack: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _onSwipe,
        child: Column(
          children: [
            Expanded(
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: SizedBox.expand(child: onboardingCollage(_index)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingProgress(
                    count: onboardingSlides.length,
                    current: _index,
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    // Keeps the controls steady between pages, but lets
                    // larger text push the artwork up instead of clipping.
                    constraints: const BoxConstraints(minHeight: 150),
                    child: FadeSlideIn(
                      key: ValueKey('copy$_index'),
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              slide.headline,
                              style: AppTypography.title,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              slide.subline,
                              style: AppTypography.bodySmall.copyWith(
                                color: p.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextAction(
                        label: 'Skip',
                        onTap: () => context.go(AppRoutes.welcome),
                      ),
                      _NextButton(
                        last: _index == onboardingSlides.length - 1,
                        onTap: _next,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap, required this.last});

  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: last ? 'Get started' : 'Continue',
      pressedScale: .94,
      haptic: HapticKind.light,
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.inverse, shape: BoxShape.circle),
        child: ArtIcon(ArtIcons.arrowRight, size: 22, color: p.onInverse),
      ),
    );
  }
}
