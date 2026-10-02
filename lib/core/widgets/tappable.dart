import 'package:flutter/widgets.dart';

import '../utils/haptics.dart';

/// A quiet press target: subtle dim + scale instead of Material ink, with
/// proper semantics and a minimum touch area.
class Tappable extends StatefulWidget {
  const Tappable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.pressedScale = .98,
    this.haptic = HapticKind.selection,
    this.behavior = HitTestBehavior.opaque,
    this.isButton = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final double pressedScale;
  final HapticKind haptic;
  final HitTestBehavior behavior;
  final bool isButton;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: widget.isButton && enabled,
      label: widget.semanticLabel,
      enabled: enabled,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                Haptics.play(widget.haptic);
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _set(false);
                Haptics.play(HapticKind.medium);
                widget.onLongPress!();
              },
        child: AnimatedScale(
          scale: _down ? widget.pressedScale : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _down ? .82 : 1,
            duration: const Duration(milliseconds: 160),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
