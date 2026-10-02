import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';

/// The design's `alFade`: rise 10pt while fading in. Plays once on mount;
/// give it a new [Key] to replay (e.g. when a chapter changes).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = AppMotion.page,
    this.delay = Duration.zero,
    this.offset = 10,
    this.curve = Curves.ease,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;
  final Curve curve;

  /// Rise from below (vertical) or drift in from the right (horizontal).
  final Axis axis;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: widget.curve,
  );
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed) return;
    if (AppMotion.reduced(context)) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _delay ??= Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: widget.axis == Axis.vertical
              ? Offset(0, widget.offset * (1 - _t.value))
              : Offset(widget.offset * (1 - _t.value), 0),
          child: child,
        ),
      ),
    );
  }
}

/// The design's `alIn`: a plain fade, once.
class FadeIn extends StatelessWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = AppMotion.page,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) =>
      FadeSlideIn(duration: duration, delay: delay, offset: 0, child: child);
}
