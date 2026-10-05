import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

enum ArtTransition {
  /// `alFade` — rise 10pt while fading in. Editorial pages.
  fadeUp,

  /// `alIn` — a plain fade. Immersive, artwork-first screens.
  fade,

  /// `cardZoom` — modern iOS card zoom / expand transition.
  /// Scaled upward glide for the incoming page, with subtle recession depth
  /// for the background page.
  cardZoom,
}

/// Builds a go_router page with the design's cinematic transitions.
Page<void> artPage(
  GoRouterState state,
  Widget child, {
  ArtTransition transition = ArtTransition.fadeUp,
  Duration? duration,
}) {
  final effectiveDuration = duration ??
      (transition == ArtTransition.cardZoom
          ? const Duration(milliseconds: 440)
          : AppMotion.page);
  final reverseDuration = transition == ArtTransition.cardZoom
      ? const Duration(milliseconds: 360)
      : const Duration(milliseconds: 380);

  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: effectiveDuration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondary, child) {
      if (AppMotion.reduced(context)) {
        return FadeTransition(opacity: animation, child: child);
      }

      if (transition == ArtTransition.cardZoom) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppMotion.cardCurve,
          reverseCurve: AppMotion.cardReverseCurve,
        );
        final opacityAnim = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
          reverseCurve: const Interval(0.35, 1.0, curve: Curves.easeIn),
        );

        final incoming = AnimatedBuilder(
          animation: curve,
          child: child,
          builder: (context, c) {
            final t = curve.value;
            final scale = 0.92 + 0.08 * t;
            final dy = 36.0 * (1.0 - t);
            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: c,
              ),
            );
          },
        );

        final page = FadeTransition(opacity: opacityAnim, child: incoming);

        final secondaryCurve = CurvedAnimation(
          parent: secondary,
          curve: AppMotion.cardCurve,
          reverseCurve: AppMotion.cardReverseCurve,
        );
        return AnimatedBuilder(
          animation: secondaryCurve,
          child: page,
          builder: (context, c) {
            final sVal = secondaryCurve.value;
            if (sVal <= 0.001) return c!;
            return Transform.scale(
              scale: 1.0 - 0.04 * sVal,
              alignment: Alignment.center,
              child: Opacity(
                opacity: 1.0 - 0.12 * sVal,
                child: c,
              ),
            );
          },
        );
      }

      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.ease,
        reverseCurve: Curves.easeIn,
      );
      Widget page = FadeTransition(opacity: fade, child: child);
      if (transition == ArtTransition.fadeUp) {
        page = AnimatedBuilder(
          animation: fade,
          child: page,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 10 * (1 - fade.value)),
            child: child,
          ),
        );
      }
      return page;
    },
  );
}

