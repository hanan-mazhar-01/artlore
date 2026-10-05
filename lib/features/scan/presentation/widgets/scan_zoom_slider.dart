import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/tappable.dart';

/// Modern zip-style camera zoom slider with graduated zipper teeth,
/// tactile scrub control, and real-time zoom readout.
class ScanZoomControl extends StatelessWidget {
  const ScanZoomControl({
    super.key,
    required this.zoom,
    required this.onZoomChanged,
  });

  final double zoom;
  final ValueChanged<double> onZoomChanged;

  void _handlePosition(double localX, double totalWidth) {
    if (totalWidth <= 0) return;
    final progress = (localX / totalWidth).clamp(0.0, 1.0);
    final rawZoom = 1.0 + progress * 2.0;
    final rounded = (rawZoom * 10).round() / 10.0;
    if ((rounded - zoom).abs() >= 0.05) {
      Haptics.play(HapticKind.selection);
      onZoomChanged(rounded.clamp(1.0, 3.0));
    }
  }

  void _nudge(double delta) {
    final next = (zoom + delta).clamp(1.0, 3.0);
    final rounded = (next * 10).round() / 10.0;
    if (rounded != zoom) {
      Haptics.play(HapticKind.selection);
      onZoomChanged(rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const trackWidth = 190.0;
    const trackHeight = 26.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: p.glass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.line(.22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current Zoom Readout Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: p.accent.withValues(alpha: .4),
                width: 0.8,
              ),
            ),
            child: Text(
              '${zoom.toStringAsFixed(1)}×',
              style: AppTypography.metadata.copyWith(
                color: p.accent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 7),
          // Zipper scrub track with minus and plus controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tappable(
                onTap: () => _nudge(-0.2),
                semanticLabel: 'Zoom out',
                pressedScale: .85,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '−',
                    style: TextStyle(
                      color: zoom > 1.05 ? p.ink : p.muted.withValues(alpha: .4),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) =>
                    _handlePosition(d.localPosition.dx, trackWidth),
                onHorizontalDragUpdate: (d) =>
                    _handlePosition(d.localPosition.dx, trackWidth),
                onTapDown: (d) =>
                    _handlePosition(d.localPosition.dx, trackWidth),
                child: SizedBox(
                  width: trackWidth,
                  height: trackHeight,
                  child: CustomPaint(
                    painter: _ZipTrackPainter(
                      zoom: zoom,
                      accentColor: p.accent,
                      lineColor: p.line(.45),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tappable(
                onTap: () => _nudge(0.2),
                semanticLabel: 'Zoom in',
                pressedScale: .85,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: zoom < 2.95 ? p.ink : p.muted.withValues(alpha: .4),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paints the zipper graduation teeth and the active runner.
class _ZipTrackPainter extends CustomPainter {
  const _ZipTrackPainter({
    required this.zoom,
    required this.accentColor,
    required this.lineColor,
  });

  final double zoom;
  final Color accentColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    const totalSteps = 20; // 1.0 to 3.0 in 0.1 intervals
    final stepWidth = size.width / totalSteps;
    final centerY = size.height / 2;

    final progress = ((zoom - 1.0) / 2.0).clamp(0.0, 1.0);
    final runnerX = progress * size.width;

    // Draw baseline track
    final basePaint = Paint()
      ..color = lineColor.withValues(alpha: .3)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      basePaint,
    );

    // Draw active gold track line
    final activeLinePaint = Paint()
      ..color = accentColor.withValues(alpha: .8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(runnerX, centerY),
      activeLinePaint,
    );

    // Draw zipper graduation teeth
    for (var i = 0; i <= totalSteps; i++) {
      final x = i * stepWidth;
      final val = 1.0 + (i * 0.1);
      final isMajor = (i % 5 == 0); // 1.0, 1.5, 2.0, 2.5, 3.0
      final isPassed = val <= (zoom + 0.03);

      final toothHeight = isMajor ? 16.0 : 8.0;
      final topY = centerY - (toothHeight / 2);
      final bottomY = centerY + (toothHeight / 2);

      final toothPaint = Paint()
        ..color = isPassed ? accentColor : lineColor
        ..strokeWidth = isMajor ? 2.0 : 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, topY), Offset(x, bottomY), toothPaint);
    }

    // Draw zipper runner (slider thumb)
    final runnerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final runnerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(runnerX, centerY),
        width: 4.5,
        height: 22.0,
      ),
      const Radius.circular(2.5),
    );

    // Subtle glow behind runner
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: .35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRRect(runnerRect, glowPaint);
    canvas.drawRRect(runnerRect, runnerPaint);
  }

  @override
  bool shouldRepaint(covariant _ZipTrackPainter oldDelegate) =>
      oldDelegate.zoom != zoom ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.lineColor != lineColor;
}
