import 'package:flutter/widgets.dart';

import '../../extensions/context_x.dart';
import '../../theme/app_motion.dart';
import '../icons/art_icon.dart';
import '../tappable.dart';
import 'art_nav_item.dart';
import 'nav_spotlight.dart';

/// ArtLore's floating pill navigation: a lamp on the pill's top edge throws
/// a soft cone of light onto the active icon, and glides to whichever item
/// the visitor picks.
///
/// Only the light layer repaints and the icons recolour while it moves —
/// the pill itself is never rebuilt by the animation.
class FloatingBottomNav extends StatefulWidget {
  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ArtNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with SingleTickerProviderStateMixin {
  /// ≈300ms for a neighbour, a touch longer for far jumps (as in the reference).
  static const _base = Duration(milliseconds: 300);
  static const _perSlot = Duration(milliseconds: 40);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _base,
    value: 1,
  );
  late SpotlightMotion _motion = SpotlightMotion.at(
    widget.selectedIndex,
    widget.items.length,
  );

  @override
  void didUpdateWidget(FloatingBottomNav old) {
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) {
      _motion = SpotlightMotion.at(widget.selectedIndex, widget.items.length);
      _progress.value = 1;
    } else if (old.selectedIndex != widget.selectedIndex) {
      _motion = _motion.retarget(widget.selectedIndex, _progress.value);
      final extra = (_motion.distance - 1).clamp(0, 3).toDouble();
      _progress.duration = _base + _perSlot * extra;
      if (AppMotion.reduced(context)) {
        _progress.value = 1;
      } else {
        _progress.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final m = FloatingNavMetrics.forScreen(
      MediaQuery.sizeOf(context).width,
      widget.items.length,
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Main navigation',
      child: Container(
        width: m.width,
        height: m.height,
        decoration: BoxDecoration(
          color: p.navPill,
          borderRadius: BorderRadius.circular(m.height / 2),
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: p.shadow.a * .5),
              offset: Offset(m.height * .05, m.height * .2),
              blurRadius: m.height * .6,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: NavSpotlightPainter(
                    progress: _progress,
                    motion: _motion,
                    metrics: m,
                    lamp: p.navLamp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.padding),
              child: Row(
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    _NavIcon(
                      item: widget.items[i],
                      metrics: m,
                      selected: i == widget.selectedIndex,
                      lit: () => _motion.weight(i, _progress.value),
                      progress: _progress,
                      onTap: () => widget.onSelected(i),
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.metrics,
    required this.selected,
    required this.lit,
    required this.progress,
    required this.onTap,
  });

  final ArtNavItem item;
  final FloatingNavMetrics metrics;
  final bool selected;

  /// Current brightness 0–1, read every frame of the move.
  final double Function() lit;
  final Animation<double> progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: metrics.slot,
      height: metrics.height,
      child: Tappable(
        onTap: onTap,
        semanticLabel: item.label,
        pressedScale: .92,
        child: Semantics(
          selected: selected,
          child: Padding(
            // Sits a hair low, under the lamp, as in the reference.
            padding: EdgeInsets.only(top: metrics.height * .06),
            child: Center(
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, _) => ArtIcon(
                  item.icon,
                  size: metrics.iconSize,
                  color: Color.lerp(p.navIcon, p.navLamp, lit()),
                  strokeWidth: 1.9,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
