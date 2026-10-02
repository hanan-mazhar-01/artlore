import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_motion.dart';
import 'analysis_controller.dart';

/// `alBreath` — gold motes drifting around the canvas. One ticker and one
/// painter drive all of them.
class AnalysisMotes extends StatefulWidget {
  const AnalysisMotes({super.key});

  @override
  State<AnalysisMotes> createState() => _AnalysisMotesState();
}

class _AnalysisMotesState extends State<AnalysisMotes>
    with SingleTickerProviderStateMixin, LoopingTicker {
  @override
  Duration get loopDuration => const Duration(seconds: 60);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _MotesPainter(loop, context.palette.accent),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _MotesPainter extends CustomPainter {
  _MotesPainter(this.t, this.color) : super(repaint: t);

  final Animation<double> t;
  final Color color;

  /// x, y (stage coordinates), period, delay — from the design.
  static const _motes = [
    (70.0, 50.0, 3.2, 0.0),
    (300.0, 100.0, 4.0, .8),
    (90.0, 320.0, 3.6, 1.4),
    (320.0, 280.0, 2.8, .4),
    (190.0, 8.0, 4.4, 2.0),
    (260.0, 370.0, 3.4, 1.1),
    (40.0, 200.0, 3.9, 2.4),
    (350.0, 190.0, 3.0, 1.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = t.value * 60;
    final paint = Paint();
    for (final (x, y, period, delay) in _motes) {
      final phase = ((seconds - delay) % period) / period;
      final wave = (1 - math.cos(phase * 2 * math.pi)) / 2;
      paint.color = color.withValues(alpha: .15 + .75 * wave);
      canvas.drawCircle(Offset(x + 1.5, y + 1.5 - 6 * wave), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_MotesPainter old) => old.color != color;
}

/// "Reading the artwork…" and its four steps.
class AnalysisStepList extends StatelessWidget {
  const AnalysisStepList({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading the artwork…',
          style: AppTypography.serif(30, italic: true),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < analysisSteps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: _StepRow(
              label: analysisSteps[i],
              done: i < step,
              current: i == step,
            ),
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.current,
  });

  final String label;
  final bool done;
  final bool current;

  static const _ease = Duration(milliseconds: 800);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      liveRegion: current,
      child: AnimatedOpacity(
        duration: _ease,
        opacity: done ? .45 : (current ? 1 : .2),
        child: Row(
          children: [
            AnimatedContainer(
              duration: _ease,
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current || done ? p.accent : p.line(.3),
                boxShadow: current
                    ? [
                        BoxShadow(
                          color: p.accentAlpha(.7),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : const [],
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: _ease,
                style: AppTypography.bodySmall.copyWith(
                  height: 1.3,
                  color: current ? p.ink : p.muted,
                ),
                child: Text(current ? '$label…' : label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
