import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../extensions/context_x.dart';
import '../theme/app_motion.dart';
import '../widgets/floating_nav/floating_bottom_nav.dart';
import 'nav_items.dart';

/// Hosts the tab branches under the floating navigation and replays the
/// design's soft fade-up when the visitor changes tab.
class TabShell extends StatefulWidget {
  const TabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: AppMotion.page,
    value: 1,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _fade,
    curve: Curves.ease,
  );

  /// While a full-screen action (Scan) is open, the light rests on it.
  int? _actionIndex;

  @override
  void didUpdateWidget(TabShell old) {
    super.didUpdateWidget(old);
    if (old.shell.currentIndex != widget.shell.currentIndex &&
        !AppMotion.reduced(context)) {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  int get _selected {
    if (_actionIndex != null) return _actionIndex!;
    final i = artNavItems.indexWhere(
      (item) => item.branch == widget.shell.currentIndex,
    );
    return math.max(0, i);
  }

  Future<void> _onSelected(int index) async {
    final item = artNavItems[index];
    final branch = item.branch;
    if (branch != null) {
      widget.shell.goBranch(
        branch,
        initialLocation: branch == widget.shell.currentIndex,
      );
      return;
    }
    // An action: light it, open it, and let the light glide home on return.
    setState(() => _actionIndex = index);
    await context.push(item.route!);
    if (mounted) setState(() => _actionIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = context.bottomInset;
    final gap = bottomInset > 0 ? math.max(12.0, bottomInset - 6) : 16.0;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _t,
            child: widget.shell,
            builder: (context, child) => Opacity(
              opacity: _t.value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - _t.value)),
                child: child,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: gap,
          child: Center(
            child: FloatingBottomNav(
              items: artNavItems,
              selectedIndex: _selected,
              onSelected: _onSelected,
            ),
          ),
        ),
      ],
    );
  }
}
