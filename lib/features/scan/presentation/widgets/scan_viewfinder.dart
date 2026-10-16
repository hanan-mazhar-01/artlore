import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_motion.dart';
import '../../../../core/widgets/design_stage.dart';

/// The corners that mark what will be scanned, laid over the live camera.
///
/// Nothing is drawn inside them and nothing is cut out: the camera simply runs
/// edge to edge behind, and whatever lies between the four corners is what
/// goes on to be scanned and analysed. [frameKey] lets the screen find the
/// frame on the glass at the moment of capture.
class ScanViewfinder extends StatefulWidget {
  const ScanViewfinder({
    super.key,
    required this.frameKey,
    required this.detected,
    this.scanning = false,
    this.ratio = autoRatio,
    this.onFocus,
  });

  final GlobalKey frameKey;
  final bool detected;
  final bool scanning;

  /// Width / height of the frame.
  final double ratio;

  /// A tap inside the frame, as a point 0–1 across and down it.
  final void Function(Offset point)? onFocus;

  /// Landscape, like most paintings.
  static const autoRatio = 330 / 272;

  @override
  State<ScanViewfinder> createState() => _ScanViewfinderState();
}

class _ScanViewfinderState extends State<ScanViewfinder>
    with TickerProviderStateMixin {
  /// A short ring where the visitor tapped to focus.
  late final AnimationController _focus = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  Offset? _focusAt;

  /// A slow breath in the corners while the camera is aiming.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _focus.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final busy = widget.scanning || widget.detected;
    final hint = widget.scanning
        ? 'Scanning artwork…'
        : widget.detected
        ? 'Hold still — tap the shutter'
        : 'Center the painting within the corners';

    return LayoutBuilder(
      builder: (context, box) {
        // As large as fits, leaving room for the hint underneath.
        final maxW = box.maxWidth - 44;
        final maxH = box.maxHeight - 70;
        final w = (maxW / widget.ratio <= maxH) ? maxW : maxH * widget.ratio;
        final h = w / widget.ratio;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: AppMotion.reveal,
              width: w,
              height: h,
              child: KeyedSubtree(
                key: widget.frameKey,
                child: LayoutBuilder(
                  builder: (context, f) => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (d) {
                      if (busy) return;
                      setState(() => _focusAt = d.localPosition);
                      _focus.forward(from: 0);
                      widget.onFocus?.call(
                        Offset(
                          (d.localPosition.dx / f.maxWidth).clamp(0.0, 1.0),
                          (d.localPosition.dy / f.maxHeight).clamp(0.0, 1.0),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _breath,
                            builder: (context, child) {
                              final b = busy
                                  ? 0.0
                                  : Curves.easeInOut.transform(_breath.value);
                              return Padding(
                                padding: EdgeInsets.all(b * 5),
                                child: child,
                              );
                            },
                            child: CornerBrackets(
                              color: p.accent,
                              radius: 22,
                              stroke: 3.4,
                              size: 46,
                            ),
                          ),
                        ),
                        if (widget.scanning)
                          const Positioned.fill(
                            child: SweepLine(
                              period: Duration(milliseconds: 1000),
                            ),
                          ),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _focus,
                            builder: (context, _) {
                              final at = _focusAt;
                              if (at == null || _focus.value == 0) {
                                return const SizedBox.expand();
                              }
                              final t = _focus.value;
                              final ring =
                                  1.45 -
                                  .45 *
                                      Curves.easeOutCubic.transform(
                                        (t / .35).clamp(0.0, 1.0),
                                      );
                              final fade = t < .7 ? 1.0 : (1 - (t - .7) / .3);
                              return CustomPaint(
                                painter: _FocusRingPainter(
                                  at: at,
                                  scale: ring,
                                  opacity: fade,
                                  color: p.accent,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: AppMotion.fast,
              child: Container(
                key: ValueKey(hint),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x8C000000),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Text(
                  hint,
                  style: AppTypography.sans(13, weight: FontWeight.w600)
                      .copyWith(
                        color: const Color(0xFFF5EFE5),
                        decoration: TextDecoration.none,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The square focus mark: it lands, settles, and fades.
class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.at,
    required this.scale,
    required this.opacity,
    required this.color,
  });

  final Offset at;
  final double scale;
  final double opacity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final half = 34.0 * scale;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: at, width: half * 2, height: half * 2),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = color.withValues(alpha: opacity),
    );
    final tick = Paint()
      ..strokeWidth = 1.8
      ..color = color.withValues(alpha: opacity);
    canvas
      ..drawLine(
        Offset(at.dx, at.dy - half),
        Offset(at.dx, at.dy - half + 6),
        tick,
      )
      ..drawLine(
        Offset(at.dx, at.dy + half),
        Offset(at.dx, at.dy + half - 6),
        tick,
      )
      ..drawLine(
        Offset(at.dx - half, at.dy),
        Offset(at.dx - half + 6, at.dy),
        tick,
      )
      ..drawLine(
        Offset(at.dx + half, at.dy),
        Offset(at.dx + half - 6, at.dy),
        tick,
      );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.at != at ||
      old.scale != scale ||
      old.opacity != opacity ||
      old.color != color;
}
