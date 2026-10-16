import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/media/art_image_source.dart';
import '../../../collections/presentation/widgets/collection_landing.dart';
import 'home_style.dart';
import 'photo_liftoff.dart';

/// One cover leaving the "My Collection" card.
class CoverCard {
  const CoverCard({
    required this.source,
    required this.start,
    required this.angle,
    required this.slot,
    required this.landDelay,
    required this.rise,
    required this.drift,
    required this.spin,
    required this.swoop,
  });

  final ArtImageSource source;

  /// Where it starts, on screen.
  final Rect start;
  final double angle;

  /// Which of the Collection grid's first cards it will land on.
  final int slot;
  final double landDelay;
  final double rise;
  final double drift;
  final double spin;
  final double swoop;
}

/// The covers on the "My Collection" card lifting off, floating up and
/// swooping down onto the first cards of the Collection page — which they
/// grow to fill, as if the collection had been made of them.
abstract final class CoverFlight {
  static const imageHeight = 210.0;

  static void play(
    BuildContext context, {
    required HomeStyle style,
    required List<CoverCard> covers,
    Duration duration = const Duration(milliseconds: 1900),
  }) {
    CollectionLanding.reset();
    CollectionLanding.count = covers.length;
    CollectionLanding.flying = true;
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CoverOverlay(
        style: style,
        covers: covers,
        duration: duration,
        onDone: () {
          CollectionLanding.flying = false;
          CollectionLanding.landed.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            entry.remove();
            entry.dispose();
          });
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _CoverOverlay extends StatefulWidget {
  const _CoverOverlay({
    required this.style,
    required this.covers,
    required this.duration,
    required this.onDone,
  });

  final HomeStyle style;
  final List<CoverCard> covers;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_CoverOverlay> createState() => _CoverOverlayState();
}

class _CoverOverlayState extends State<_CoverOverlay>
    with SingleTickerProviderStateMixin {
  static const _split = .36;

  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onDone();
        })
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final origin =
        widget.covers.fold<Offset>(Offset.zero, (a, c) => a + c.start.center) /
        widget.covers.length.toDouble();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final children = <Widget>[
              ...flightRing(t, origin, s),
              ...flightSparks(t, origin, s),
            ];
            var nearest = 0.0;
            // Back to front: the last cover is drawn first, the newest on top.
            for (final c in widget.covers.reversed) {
              final u1 = (t / _split).clamp(0.0, 1.0);
              final lift = Curves.easeOutCubic.transform(u1);
              final sway =
                  math.sin(u1 * math.pi * 2.2) * 6 * math.sin(u1 * math.pi);
              final grow =
                  1 +
                  .5 * Curves.easeOutCubic.transform((u1 * 1.4).clamp(0, 1));
              final apexCenter = c.start.center + Offset(c.drift, -c.rise);
              final apexSize = c.start.size * 1.5;
              var center =
                  c.start.center +
                  Offset(
                    c.drift * Curves.easeOut.transform(u1) + sway,
                    -c.rise * lift,
                  );
              var size = c.start.size * grow;
              var angle = c.angle + c.spin * Curves.easeInOut.transform(u1);
              var radius = 7.0;
              var shadowLift = lift;
              var opacity = 1.0;

              final d = ((t - _split) / (1 - _split)).clamp(0.0, 1.0);
              final u2 = ((d - c.landDelay) / (1 - c.landDelay)).clamp(
                0.0,
                1.0,
              );
              if (u2 > 0 || t > _split) {
                final k = Curves.easeInOutCubic.transform(u2);
                final target = CollectionLanding.targetRect(
                  c.slot,
                  CoverFlight.imageHeight,
                );
                final restAngle = c.angle + c.spin;
                if (target != null) {
                  final swing = math.sin(k * math.pi) * c.swoop;
                  center =
                      Offset.lerp(apexCenter, target.center, k)! +
                      Offset(swing, 0);
                  size = Size.lerp(apexSize, target.size, k)!;
                  angle = restAngle * (1 - k);
                  radius = 7 + (26 - 7) * k;
                  shadowLift = lift * (1 - k);
                  nearest = math.max(nearest, k);
                } else {
                  center = apexCenter + Offset(0, -60 * k);
                  size = apexSize;
                  angle = restAngle;
                  opacity = 1 - k;
                }
              }

              children.add(
                Positioned(
                  left: center.dx - size.width / 2,
                  top: center.dy - size.height / 2,
                  width: size.width,
                  height: size.height,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: angle,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          boxShadow: [
                            BoxShadow(
                              color: s.shadow(.3 + .12 * shadowLift),
                              offset: Offset(0, 4 + 16 * shadowLift),
                              blurRadius: 8 + 20 * shadowLift,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Image(
                            image: ResizeImage.resizeIfNeeded(
                              560,
                              null,
                              c.source.provider(),
                            ),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CollectionLanding.approach.value = nearest;
            });
            return Stack(clipBehavior: Clip.none, children: children);
          },
        ),
      ),
    );
  }
}
