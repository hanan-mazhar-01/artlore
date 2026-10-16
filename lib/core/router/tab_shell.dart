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
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = context.bottomInset;
    final gap = bottomInset > 0 ? math.max(12.0, bottomInset - 6) : 16.0;
    // The nav after the mock-up: tabs and the scan button's end make one pill.
    final m = FloatingNavMetrics.mock(
      MediaQuery.sizeOf(context).width,
      artNavItems.length,
    );
    final extra = ScanFabDock.extraWidth(m.height);
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
              // One pill: the tabs and, at its right end, the scan button.
              child: SizedBox(
                width: m.width + extra,
                height: m.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingBottomNav(
                      items: artNavItems,
                      selectedIndex: _selected,
                      onSelected: _onSelected,
                      metrics: m,
                      extra: extra,
                    ),
                    Positioned(
                      // Centred on the pill's right cap.
                      left:
                          m.width +
                          extra -
                          m.height / 2 -
                          ScanFabDock.ringWidth(m.height) / 2,
                      top: 0,
                      child: ScanFabDock(
                        pillHeight: m.height,
                        onTap: () => context.push(AppRoutes.scan),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
