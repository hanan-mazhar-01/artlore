import 'package:flutter/widgets.dart';

/// A fixed-height backdrop with content that starts [overlap] points before
/// the backdrop ends — the design's negative `margin-top`, with correct
/// layout height (unlike a translate).
class OverlapLayout extends StatelessWidget {
  const OverlapLayout({
    super.key,
    required this.backdrop,
    required this.backdropHeight,
    required this.overlap,
    required this.child,
    this.foreground = const [],
  });

  final Widget backdrop;
  final double backdropHeight;
  final double overlap;
  final Widget child;

  /// Extra layers painted above everything (e.g. floating buttons).
  final List<Widget> foreground;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: backdropHeight,
          child: backdrop,
        ),
        Padding(
          padding: EdgeInsets.only(top: backdropHeight - overlap),
          child: child,
        ),
        ...foreground,
      ],
    );
  }
}
