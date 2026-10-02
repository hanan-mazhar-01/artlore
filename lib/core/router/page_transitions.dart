import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

enum ArtTransition {
  /// `alFade` — rise 10pt while fading in. Editorial pages.
  fadeUp,

  /// `alIn` — a plain fade. Immersive, artwork-first screens.
  fade,
}

/// Builds a go_router page with the design's slow, cinematic transitions.
Page<void> artPage(
  GoRouterState state,
  Widget child, {
  ArtTransition transition = ArtTransition.fadeUp,
  Duration duration = AppMotion.page,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (context, animation, secondary, child) {
      if (AppMotion.reduced(context)) {
        return FadeTransition(opacity: animation, child: child);
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
