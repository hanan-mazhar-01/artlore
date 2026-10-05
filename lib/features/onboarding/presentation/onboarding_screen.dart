import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/buttons.dart';
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
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < onboardingSlides.length - 1) {
      Haptics.play(HapticKind.selection);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Haptics.play(HapticKind.light);
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final slide = onboardingSlides[_index];
    final bottomPad = math.max(28.0, context.bottomInset + 10);
    return ArtScaffold(
      swipeBack: false,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingSlides.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) {
                if (i != _index) {
                  Haptics.play(HapticKind.selection);
                  setState(() => _index = i);
                }
              },
              itemBuilder: (context, i) => KeyedSubtree(
                key: ValueKey(i),
                child: SizedBox.expand(child: onboardingCollage(i)),
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
                  constraints: const BoxConstraints(minHeight: 150),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_index),
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
      pressedScale: .92,
      haptic: HapticKind.light,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: last ? p.accent : p.inverse,
          shape: BoxShape.circle,
          boxShadow: last
              ? [
                  BoxShadow(
                    color: p.accentAlpha(.4),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: ArtIcon(
            ArtIcons.arrowRight,
            key: ValueKey(last),
            size: 22,
            color: last ? p.onAccent : p.onInverse,
          ),
        ),
      ),
    );
  }
}
