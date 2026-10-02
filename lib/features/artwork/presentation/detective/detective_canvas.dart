import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/color_filters.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../domain/artwork.dart';
import '../../domain/detective_case.dart';
import 'detective_controller.dart';

/// The tappable canvas: miss ripples, the hint glow and the found ring.
class DetectiveCanvas extends StatelessWidget {
  const DetectiveCanvas({
    super.key,
    required this.artwork,
    required this.detectiveCase,
    required this.state,
    required this.onTap,
  });

  final Artwork artwork;
  final DetectiveCase detectiveCase;
  final DetectiveState state;
  final bool Function(Offset tap, Size box) onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 244,
        child: LayoutBuilder(
          builder: (context, c) {
            final box = c.biggest;
            final target = DetectiveController.targetIn(
              detectiveCase,
              box,
              artwork.image.aspect,
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final hit = onTap(d.localPosition, box);
                Haptics.play(hit ? HapticKind.success : HapticKind.light);
              },
              child: Semantics(
                label: 'Painting. Tap where you think the detail hides.',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: state.found ? 1 : .85),
                        duration: const Duration(seconds: 1),
                        child: ArtImage(artwork.image),
                        builder: (context, s, child) => ColorFiltered(
                          colorFilter: ColorFilters.grade(saturation: s),
                          child: child,
                        ),
                      ),
                    ),
                    if (state.hint && !state.found)
                      Positioned(
                        left: target.dx - box.width * .2,
                        top: target.dy - box.height * .22,
                        width: box.width * .4,
                        height: box.height * .44,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [p.accentAlpha(.28), p.accentAlpha(0)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    for (final t in state.taps)
                      Positioned(
                        key: ValueKey(t.id),
                        left: t.position.dx - 22,
                        top: t.position.dy - 22,
                        child: const _MissRipple(),
                      ),
                    if (state.found)
                      Positioned(
                        left: target.dx - 35,
                        top: target.dy - 35,
                        child: const _FoundRing(),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// `alMiss` — a ring that widens and fades.
class _MissRipple extends StatelessWidget {
  const _MissRipple();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
        builder: (context, t, _) => Opacity(
          opacity: (.9 * (1 - t)).clamp(0, 1),
          child: Transform.scale(
            scale: .4 + 1.2 * t,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: p.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `alFound` — the gold ring settles while the rest of the canvas dims.
class _FoundRing extends StatelessWidget {
  const _FoundRing();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: AppMotion.sheet,
        builder: (context, t, _) => Opacity(
          opacity: (t / .6).clamp(0, 1),
          child: Transform.scale(
            scale: .3 + .7 * t,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: p.accent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: p.deep.withValues(alpha: .45),
                    spreadRadius: 999,
                  ),
                  BoxShadow(color: p.accentAlpha(.6), blurRadius: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
