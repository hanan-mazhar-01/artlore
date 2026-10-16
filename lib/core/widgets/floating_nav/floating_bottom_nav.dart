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
    required this.metrics,
    this.extra = 0,
  });

  final List<ArtNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Computed by the caller, so anything sharing its row (the scan button)
  /// sizes off the exact same numbers — never recomputed in here.
  final FloatingNavMetrics metrics;

  /// Extra pill past the tabs — the scan button's end — so the pill is
  /// one piece and the lamp can reach right across it.
  final double extra;

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with TickerProviderStateMixin {
  /// ≈300ms for a neighbour, a touch longer for far jumps (as in the reference).
  static const _base = Duration(milliseconds: 300);
  static const _perSlot = Duration(milliseconds: 40);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _base,
    value: 1,
  );

  /// The lamp's slow breathing.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final m = widget.metrics;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Main navigation',
      child: Container(
        width: m.width + widget.extra,
        height: m.height,
        // A fine glass edge, painted over the pill (not as a layout border)
        // so it can't eat into the width the icon row was measured against.
        foregroundDecoration: _GlassEdge(
          dark: context.isDark,
          lightColor: p.accentAlpha(.45),
        ),
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
                    breath: _breath,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: m.width,
              child: Padding(
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

/// The pill's rim: a faint white on dark, and on light the app's own brown
/// (the same accent the other bordered elements use).
class _GlassEdge extends Decoration {
  const _GlassEdge({required this.dark, required this.lightColor});

  final bool dark;
  final Color lightColor;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _GlassEdgePainter(dark, lightColor);
}

class _GlassEdgePainter extends BoxPainter {
  _GlassEdgePainter(this.dark, this.lightColor);

  final bool dark;
  final Color lightColor;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    const width = 0.8;
    final rrect = RRect.fromRectAndRadius(
      (offset & size).deflate(width / 2),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..isAntiAlias = true
        ..color = dark
            ? const Color(0xFFFFFFFF).withValues(alpha: .16)
            : lightColor,
    );
  }
}
