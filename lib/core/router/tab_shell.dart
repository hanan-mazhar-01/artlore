import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../extensions/context_x.dart';
import '../widgets/floating_nav/art_nav_item.dart';
import '../widgets/floating_nav/floating_bottom_nav.dart';
import '../widgets/floating_nav/scan_fab_dock.dart';
import 'app_routes.dart';
import 'nav_items.dart';

/// Exposes the active branch index to descendants in the shell tree.
class ActiveTabScope extends InheritedWidget {
  const ActiveTabScope({
    super.key,
    required this.currentIndex,
    required super.child,
  });

  final int currentIndex;

  static int of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ActiveTabScope>()
            ?.currentIndex ??
        0;
  }

  @override
  bool updateShouldNotify(ActiveTabScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

/// Hosts the tab branches under the floating navigation.
/// Tabs switch instantly with zero transition.
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  int get _selected {
    final i = artNavItems.indexWhere(
      (item) => item.branch == shell.currentIndex,
    );
    return math.max(0, i);
  }

  void _onSelected(int index) {
    final branch = artNavItems[index].branch;
    shell.goBranch(
      branch,
      initialLocation: branch == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = context.bottomInset;
    final gap = bottomInset > 0 ? math.max(12.0, bottomInset - 6) : 16.0;
    // Reserve room for the scan button + its gap so the pill shrinks to
    // make space for it, rather than the pair crowding the screen edge.
    const fabGap = 24.0;
    const fabScale = 1.05; // a touch bigger than the pill it sits beside.
    const fabMaxDiameter = 64.0 * fabScale;
    final m = FloatingNavMetrics.forScreen(
      MediaQuery.sizeOf(context).width,
      artNavItems.length,
      reservedWidth: fabGap + fabMaxDiameter,
    );
    final fabDiameter = m.height * fabScale;
    return ActiveTabScope(
      currentIndex: shell.currentIndex,
      child: Stack(
        children: [
          Positioned.fill(child: shell),
          Positioned(
            left: 0,
            right: 0,
            bottom: gap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingBottomNav(
                    items: artNavItems,
                    selectedIndex: _selected,
                    onSelected: _onSelected,
                    metrics: m,
                  ),
                  ScanFabDock(
                    diameter: fabDiameter,
                    pillHeight: m.height,
                    onTap: () => context.push(AppRoutes.scan),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
