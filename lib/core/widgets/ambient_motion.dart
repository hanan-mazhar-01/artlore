import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../media/art_image_source.dart';
import '../theme/app_motion.dart';
import '../theme/app_shadows.dart';
import 'art_image.dart';

/// Drives a looping animation that pauses itself when motion is reduced.
mixin LoopingTicker<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  Duration get loopDuration;
  bool get loopReverse => false;

  late final AnimationController loop = AnimationController(
    vsync: this,
    duration: loopDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      loop.stop();
    } else if (!loop.isAnimating) {
      loop.repeat(reverse: loopReverse);
    }
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }
}

/// `alSweep` — a glowing gold line travelling top → bottom, forever.
/// Fills its parent; place it inside a sized box or Positioned.fill.
class SweepLine extends StatefulWidget {
  const SweepLine({super.key, this.period = const Duration(seconds: 2)});

  final Duration period;

  @override
  State<SweepLine> createState() => _SweepLineState();
}

class _SweepLineState extends State<SweepLine>
    with SingleTickerProviderStateMixin, LoopingTicker {
  @override
  Duration get loopDuration => widget.period;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final line = DecoratedBox(
      decoration: BoxDecoration(
        color: p.accent,
        boxShadow: AppShadows.sweepGlow(p),
      ),
      child: const SizedBox(height: 1, width: double.infinity),
    );
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, c) => AnimatedBuilder(
            animation: loop,
            child: line,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(loop.value);
              final fade = t < .1 ? t / .1 : (t > .9 ? (1 - t) / .1 : 1.0);
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: t * c.maxHeight,
                    child: Opacity(opacity: fade.clamp(0, 1), child: child),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// `alDrift` — a slow Ken Burns drift for cinematic backdrops.
class DriftImage extends StatefulWidget {
  const DriftImage(
    this.source, {
    super.key,
    this.period = const Duration(seconds: 18),
    this.alignment = Alignment.center,
  });

  final ArtImageSource source;
  final Duration period;
  final Alignment alignment;

  @override
  State<DriftImage> createState() => _DriftImageState();
}

class _DriftImageState extends State<DriftImage>
    with SingleTickerProviderStateMixin, LoopingTicker {
  @override
  Duration get loopDuration => widget.period;
  @override
  bool get loopReverse => true;

  @override
  Widget build(BuildContext context) {
    final image = ArtImage(
      widget.source,
      alignment: widget.alignment,
      decodeScale: 1.15,
    );
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, c) => AnimatedBuilder(
          animation: loop,
          child: RepaintBoundary(child: image),
          builder: (context, child) {
            final t = Curves.easeInOut.transform(loop.value);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translateByDouble(c.maxWidth * (-.02 + .04 * t), 0, 0, 1)
                ..scaleByDouble(1.08 + .06 * t, 1.08 + .06 * t, 1, 1),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
