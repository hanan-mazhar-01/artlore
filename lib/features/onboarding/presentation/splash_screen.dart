import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../settings/presentation/settings_controller.dart';

/// A single gold point, then the wordmark settles out of a blur.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3100),
  );
  late final _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final _dot = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, .18, curve: Curves.easeOut),
  );
  late final _word = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.29, .87, curve: AppMotion.reveal),
  );
  late final _tagline = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.61, 1, curve: Curves.ease),
  );
  Timer? _next;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _intro.addListener(_startGlow);
    _next = Timer(const Duration(milliseconds: 3400), _continue);
  }

  void _startGlow() {
    if (_intro.value > .45 && !_glow.isAnimating && mounted) {
      _intro.removeListener(_startGlow);
      if (!AppMotion.reduced(context)) _glow.repeat(reverse: true);
    }
  }

  void _continue() {
    if (_left || !mounted) return;
    _left = true;
    final done = ref.read(settingsProvider).onboardingComplete;
    context.go(done ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _next?.cancel();
    _intro.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ArtScaffold(
      swipeBack: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continue,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _glow]),
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoldPoint(appear: _dot.value, glow: _glow.value),
                const SizedBox(height: 28),
                _Wordmark(t: _word.value),
                const SizedBox(height: 10),
                Opacity(
                  opacity: _tagline.value,
                  child: Text(
                    'A GALLERY IN YOUR HAND',
                    style: AppTypography.sans(
                      10,
                      tracking: .32,
                    ).copyWith(color: p.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldPoint extends StatelessWidget {
  const _GoldPoint({required this.appear, required this.glow});

  final double appear;
  final double glow;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final g = Curves.easeInOut.transform(glow);
    return Opacity(
      opacity: appear,
      child: Transform.scale(
        scale: appear,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: p.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: p.accentAlpha(.35 + .2 * g),
                blurRadius: 18 + 16 * g,
                spreadRadius: 4 + 6 * g,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'ArtLore',
      style: AppTypography.serif(
        46,
        weight: FontWeight.w500,
        tracking: .32 - .30 * t,
      ),
    );
    final blur = 6 * (1 - t);
    return Opacity(
      opacity: t,
      child: blur < .05
          ? text
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: text,
            ),
    );
  }
}
