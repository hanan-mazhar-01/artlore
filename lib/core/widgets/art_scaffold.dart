import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../extensions/context_x.dart';

/// Page host for every ArtLore screen: the gallery ground, the right status
/// bar contrast, and an iOS-style edge swipe to go back.
class ArtScaffold extends StatelessWidget {
  const ArtScaffold({
    super.key,
    required this.body,
    this.background,
    this.forceLightStatusBar = false,
    this.swipeBack = true,
  });

  final Widget body;
  final Color? background;

  /// Keep light status-bar glyphs (camera, artwork-first screens).
  final bool forceLightStatusBar;
  final bool swipeBack;

  @override
  Widget build(BuildContext context) {
    final light = forceLightStatusBar || context.isDark;
    final overlay =
        (light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            );
    Widget content = Material(
      color: background ?? context.palette.background,
      child: body,
    );
    if (swipeBack) content = _EdgeSwipeBack(child: content);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: content,
    );
  }
}

/// Pops the route when the user swipes in from the left edge. Pages fade
/// rather than slide (the design's transition), so the gesture is added here.
class _EdgeSwipeBack extends StatefulWidget {
  const _EdgeSwipeBack({required this.child});

  final Widget child;

  @override
  State<_EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<_EdgeSwipeBack> {
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    if (!GoRouter.of(context).canPop()) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 18,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _dx = 0,
            onHorizontalDragUpdate: (d) => _dx += d.delta.dx,
            onHorizontalDragEnd: (d) {
              final fling = (d.primaryVelocity ?? 0) > 450;
              if ((_dx > 80 || fling) && context.canPop()) context.pop();
            },
          ),
        ),
      ],
    );
  }
}

/// iOS-feel scrolling everywhere: bounce, no glow, no scrollbars.
class ArtScrollBehavior extends MaterialScrollBehavior {
  const ArtScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildScrollbar(BuildContext context, Widget child, details) => child;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
