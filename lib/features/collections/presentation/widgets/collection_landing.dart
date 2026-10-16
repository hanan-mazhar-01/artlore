import 'package:flutter/material.dart';

/// Where the cover cards flying in from Home's "My Collection" come to rest:
/// the first cards of the Collection grid. The grid reports where each one
/// is, holds an outline in its place while the covers are on their way, and
/// shows the real card the moment the cover lands on it.
abstract final class CollectionLanding {
  /// One key per landing card (the first three of the grid).
  static final keys = List<GlobalKey>.generate(3, (_) => GlobalKey());

  /// A flight is under way, and how many covers it carries.
  static bool flying = false;
  static int count = 0;

  /// The covers are close: the outlines fade.
  static final approach = ValueNotifier<double>(0);

  /// The covers have landed: the real cards take over.
  static final landed = ValueNotifier<bool>(false);

  static void reset() {
    flying = false;
    count = 0;
    approach.value = 0;
    landed.value = false;
  }

  /// Where the cover for card [i] should land, in screen coordinates — the
  /// image area of that card — or null while it is not on screen.
  static Rect? targetRect(int i, double imageHeight) {
    final box = keys[i].currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(origin.dx, origin.dy, box.size.width, imageHeight);
  }
}

/// Wraps one of the first grid cards: reports its position, and — while covers
/// are flying in — shows an outline in its place instead of the card.
class CollectionLandingSlot extends StatelessWidget {
  const CollectionLandingSlot({
    super.key,
    required this.index,
    required this.imageHeight,
    required this.radius,
    required this.child,
  });

  final int index;
  final double imageHeight;
  final BorderRadius radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: CollectionLanding.keys[index],
      child: ListenableBuilder(
        listenable: Listenable.merge([
          CollectionLanding.landed,
          CollectionLanding.approach,
        ]),
        builder: (context, _) {
          final waiting =
              CollectionLanding.flying &&
              !CollectionLanding.landed.value &&
              index < CollectionLanding.count;
          if (!waiting) return child;
          final near = CollectionLanding.approach.value;
          return Stack(
            children: [
              Opacity(opacity: 0, child: child),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: imageHeight,
                child: Opacity(
                  opacity: 1 - ((near - .5) / .5).clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: const Color(0xFFD9B46E).withValues(alpha: .5),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
