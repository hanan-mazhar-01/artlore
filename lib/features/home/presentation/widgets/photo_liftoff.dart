import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import 'home_style.dart';

/// One small photo card: a pale border, rounded corners and a soft shadow that
/// deepens as the card [lift]s off the page (0 resting, 1 high in the air).
class PhotoCardFace extends StatelessWidget {
  const PhotoCardFace({
    super.key,
    required this.style,
    required this.bytes,
    this.lift = 0,
  });

  static const width = 44.0;
  static const height = 56.0;

  final HomeStyle style;
  final Uint8List? bytes;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: s.onImage,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: s.shadow(.28 + .12 * lift),
            offset: Offset(0, 4 + 16 * lift),
            blurRadius: 8 + 20 * lift,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: bytes == null
            ? ColoredBox(
                color: s.tile,
                child: Center(
                  child: ArtIcon(ArtIcons.photos, size: 16, color: s.goldDeep),
                ),
              )
            : Image.memory(
                bytes!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              ),
      ),
    );
  }
}

/// How one card travels.
class LiftCard {
  const LiftCard({
    required this.center,
    required this.angle,
    required this.bytes,
    required this.landDelay,
    required this.rise,
    required this.drift,
    required this.spin,
    required this.swoop,
    required this.landOffset,
    required this.landAngle,
  });

  /// Where it starts (screen coordinates, its centre) and its resting tilt.
  final Offset center;
  final double angle;
  final Uint8List? bytes;

  /// How long (as a share of the descent) it hangs back before coming down.
  final double landDelay;

  /// How far up it floats (px), how far it drifts sideways (px) and how much it
  /// turns on the way up (radians).
  final double rise;
  final double drift;
  final double spin;

  /// How wide a curve it swings on the way down (px, signed).
  final double swoop;

  /// Where it comes to rest relative to the landing slot's centre, and its
  /// tilt there.
  final Offset landOffset;
  final double landAngle;
}

/// The landing spot for the flying cards: the slot inside the picker sheet's
/// "Choose from Device Gallery" button. The slot reports where it is, and
/// swaps its icon for the two small cards once they have arrived.
abstract final class PhotoLanding {
  static final slotKey = GlobalKey();

  /// The two photos, newest first, and how to draw them.
  static List<Uint8List?> photos = const [];
  static HomeStyle? style;

  /// The cards are close: the slot's icon fades out beneath them.
  static final approach = ValueNotifier<double>(0);

  /// The cards have arrived: the slot shows them itself.
  static final landed = ValueNotifier<bool>(false);

  static Offset? slotCenter() {
    final box = slotKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  static void reset() {
    flying = false;
    approach.value = 0;
    landed.value = false;
  }

  /// The cards keep the size they have on the Home card.
  static const scale = 1.0;

  /// A flight is in progress, bound for the slot.
  static bool flying = false;

  /// Remember the photos and look the slot should show, flight or not.
  static void prepare(List<Uint8List?> photos, HomeStyle style) {
    PhotoLanding.photos = photos;
    PhotoLanding.style = style;
  }

  /// Where the two cards rest inside the slot, relative to its centre, and
  /// their tilts — the same arrangement as on the Home card.
  static const backOffset = Offset(-19, 3);
  static const frontOffset = Offset(13, -3);
  static const backAngle = -.13;
  static const frontAngle = .12;
}

/// The two photo cards leaving the Home card: they lift, drift apart and
/// float up turning slowly, hang for a breath, then swoop down into the
/// picker sheet and settle into its "Choose from Device Gallery" button — as
/// if the button had taken them in. Played on a layer above everything, so the
/// sheet rising beneath reads as what they were carrying.
abstract final class PhotoLiftOff {
  static void play(
    BuildContext context, {
    required HomeStyle style,
    required List<LiftCard> cards,
    required List<Uint8List?> photos,
    Duration duration = const Duration(milliseconds: 1900),
  }) {
    PhotoLanding.reset();
    PhotoLanding.prepare(photos, style);
    PhotoLanding.flying = true;
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _LiftOff(
        style: style,
        cards: cards,
        duration: duration,
        onDone: () {
          // The slot takes over drawing the cards; leave the layer a frame
          // later so there is never a moment with neither.
          PhotoLanding.flying = false;
          PhotoLanding.landed.value = true;
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

class _LiftOff extends StatefulWidget {
  const _LiftOff({
    required this.style,
    required this.cards,
    required this.duration,
    required this.onDone,
  });

  final HomeStyle style;
  final List<LiftCard> cards;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_LiftOff> createState() => _LiftOffState();
}

class _LiftOffState extends State<_LiftOff>
    with SingleTickerProviderStateMixin {
  /// The share of the flight spent going up; the rest is the descent.
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
        widget.cards.fold<Offset>(Offset.zero, (a, c) => a + c.center) /
        widget.cards.length.toDouble();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final slot = PhotoLanding.slotCenter();
            final children = <Widget>[];

            children
              ..addAll(flightRing(t, origin, s))
              ..addAll(flightSparks(t, origin, s));

            // The cards, back one first so the front one stays on top.
            var nearest = 0.0;
            for (final c in widget.cards) {
              // Going up.
              final u1 = (t / _split).clamp(0.0, 1.0);
              final lift = Curves.easeOutCubic.transform(u1);
              final sway =
                  math.sin(u1 * math.pi * 2.2) * 6 * math.sin(u1 * math.pi);
              final apex = c.center + Offset(c.drift, -c.rise);
              var pos =
                  c.center +
                  Offset(
                    c.drift * Curves.easeOut.transform(u1) + sway,
                    -c.rise * lift,
                  );
              var angle = c.angle + c.spin * Curves.easeInOut.transform(u1);
              var scale =
                  1 +
                  .32 * Curves.easeOutCubic.transform((u1 * 1.4).clamp(0, 1));
              var shadowLift = lift;
              var opacity = 1.0;

              // Coming down into the sheet.
              final d = ((t - _split) / (1 - _split)).clamp(0.0, 1.0);
              final u2 = ((d - c.landDelay) / (1 - c.landDelay)).clamp(
                0.0,
                1.0,
              );
              if (u2 > 0 || t > _split) {
                final k = Curves.easeInOutCubic.transform(u2);
                final restAngle = c.angle + c.spin;
                if (slot != null) {
                  final target = slot + c.landOffset;
                  // A swing out to the side, so the way down is a curve and
                  // not a straight drop.
                  final swing = math.sin(k * math.pi) * c.swoop;
                  pos = Offset.lerp(apex, target, k)! + Offset(swing, 0);
                  scale = 1.32 + (PhotoLanding.scale - 1.32) * k;
                  angle = restAngle + (c.landAngle - restAngle) * k;
                  shadowLift = lift * (1 - k);
                  nearest = math.max(nearest, k);
                } else {
                  // The sheet has gone: let them drift off and fade.
                  pos = apex + Offset(0, -60 * k);
                  opacity = 1 - k;
                }
              }

              children.add(
                Positioned(
                  left: pos.dx - PhotoCardFace.width / 2,
                  top: pos.dy - PhotoCardFace.height / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: angle,
                      child: Transform.scale(
                        scale: scale,
                        child: PhotoCardFace(
                          style: s,
                          bytes: c.bytes,
                          lift: shadowLift,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            // Tell the slot how close they are, so its icon can step aside.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              PhotoLanding.approach.value = nearest;
            });
            return Stack(clipBehavior: Clip.none, children: children);
          },
        ),
      ),
    );
  }
}

/// The slot inside the "Choose from Device Gallery" button that takes in the
/// two flying cards. While they are on their way it shows an empty outline of
/// each, where they will rest; once they arrive it holds the cards themselves,
/// at the size and tilt they have on the Home card.
class PhotoLandingSlot extends StatelessWidget {
  const PhotoLandingSlot({super.key});

  static const width = 82.0;
  static const height = 66.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: PhotoLanding.slotKey,
      width: width,
      height: height,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          PhotoLanding.landed,
          PhotoLanding.approach,
        ]),
        builder: (context, _) {
          final style = PhotoLanding.style ?? HomeStyle.of(context);
          final photos = PhotoLanding.photos;
          final waiting = PhotoLanding.flying && !PhotoLanding.landed.value;
          // Positions inside the slot, matching the Home card's pair.
          Widget placed(Offset centre, double angle, Widget child) {
            return Positioned(
              left: width / 2 + centre.dx - PhotoCardFace.width / 2,
              top: height / 2 + centre.dy - PhotoCardFace.height / 2,
              child: Transform.rotate(angle: angle, child: child),
            );
          }

          if (waiting) {
            // Empty outlines that fade as the real cards come in.
            final ghost = Opacity(
              opacity:
                  1 - ((PhotoLanding.approach.value - .5) / .5).clamp(0.0, 1.0),
              child: Container(
                width: PhotoCardFace.width,
                height: PhotoCardFace.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: style.gold.withValues(alpha: .45),
                    width: 1.2,
                  ),
                ),
              ),
            );
            return Stack(
              clipBehavior: Clip.none,
              children: [
                placed(PhotoLanding.backOffset, PhotoLanding.backAngle, ghost),
                placed(
                  PhotoLanding.frontOffset,
                  PhotoLanding.frontAngle,
                  ghost,
                ),
              ],
            );
          }
          // They arrive with a small settle, as if dropped into place.
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.08, end: 1),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                placed(
                  PhotoLanding.backOffset,
                  PhotoLanding.backAngle,
                  PhotoCardFace(
                    style: style,
                    bytes: photos.length > 1 ? photos[1] : null,
                  ),
                ),
                placed(
                  PhotoLanding.frontOffset,
                  PhotoLanding.frontAngle,
                  PhotoCardFace(
                    style: style,
                    bytes: photos.isNotEmpty ? photos[0] : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A ring that opens from the point the cards are released.
List<Widget> flightRing(double t, Offset origin, HomeStyle s) {
  final ring = Curves.easeOutCubic.transform((t / .24).clamp(0.0, 1.0));
  if (ring >= 1) return const [];
  final r = 26 + 74 * ring;
  return [
    Positioned(
      left: origin.dx - r,
      top: origin.dy - r,
      width: r * 2,
      height: r * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: s.gold.withValues(alpha: .55 * (1 - ring)),
            width: 1.5,
          ),
        ),
      ),
    ),
  ];
}

/// Small sparks that rise and fade behind the flying cards.
List<Widget> flightSparks(double t, Offset origin, HomeStyle s) {
  double smooth(double a, double b, double x) {
    final u = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return u * u * (3 - 2 * u);
  }

  final out = <Widget>[];
  for (var i = 0; i < 9; i++) {
    final seed = i * 12.9898;
    final fx = (math.sin(seed) * 43758.5453).abs() % 1;
    final fy = (math.sin(seed + 3.1) * 24634.6345).abs() % 1;
    final delay = .03 + fx * .12;
    final u = ((t - delay) / (.5 - delay)).clamp(0.0, 1.0);
    if (u <= 0 || u >= 1) continue;
    final rise = 90 + 230 * fy;
    final x = origin.dx + (fx - .5) * 130 + math.sin(u * 5 + i) * 8;
    final y = origin.dy - rise * Curves.easeOutCubic.transform(u);
    final a = (1 - smooth(.35, 1, u)) * .8;
    final d = 2.5 + 3 * fy;
    out.add(
      Positioned(
        left: x - d / 2,
        top: y - d / 2,
        width: d,
        height: d,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: s.goldLight.withValues(alpha: a),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: s.gold.withValues(alpha: a * .8), blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
  return out;
}
