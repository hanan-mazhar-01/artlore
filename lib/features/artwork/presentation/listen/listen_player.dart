import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork_content.dart';
import 'listen_controller.dart';

/// Chapter-ticked scrubber, times and transport controls.
class ListenPlayer extends ConsumerWidget {
  const ListenPlayer({super.key, required this.narration});

  final Narration narration;

  static String _fmt(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final provider = listenControllerProvider(narration);
    final state = ref.watch(provider);
    final ctl = ref.read(provider.notifier);
    final duration = ctl.duration;
    final progress = (state.position / duration).clamp(0.0, 1.0);
    final ticks = narration.chapters.length;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => ctl.seekFraction(d.localPosition.dx / c.maxWidth),
            onHorizontalDragUpdate: (d) =>
                ctl.seekFraction(d.localPosition.dx / c.maxWidth),
            child: Semantics(
              slider: true,
              label: 'Narration position',
              value: _fmt(state.position),
              child: SizedBox(
                height: 22,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 10,
                      height: 1,
                      child: ColoredBox(color: p.line(.2)),
                    ),
                    Positioned(
                      left: 0,
                      top: 10,
                      height: 1,
                      width: c.maxWidth * progress,
                      child: ColoredBox(color: p.accent),
                    ),
                    for (var i = 1; i < ticks; i++)
                      Positioned(
                        left: c.maxWidth * i / ticks,
                        top: 6,
                        width: 1,
                        height: 9,
                        child: ColoredBox(color: p.line(.35)),
                      ),
                    Positioned(
                      left: c.maxWidth * progress - 5.5,
                      top: 5,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: p.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: p.accentAlpha(.6), blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_fmt(state.position), style: _time(p.muted)),
            Text('-${_fmt(duration - state.position)}', style: _time(p.muted)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Skip(
              icon: ArtIcons.rewind,
              label: 'Back 15 seconds',
              onTap: () => ctl.skip(-15),
            ),
            const SizedBox(width: 44),
            Tappable(
              onTap: ctl.toggle,
              semanticLabel: state.playing ? 'Pause' : 'Play',
              haptic: HapticKind.light,
              pressedScale: .95,
              child: Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.inverse,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: p.line(.06), spreadRadius: 8)],
                ),
                child: ArtIcon(
                  state.playing ? ArtIcons.pause : ArtIcons.play,
                  size: 24,
                  color: p.onInverse,
                ),
              ),
            ),
            const SizedBox(width: 44),
            _Skip(
              icon: ArtIcons.forward,
              label: 'Forward 15 seconds',
              onTap: () => ctl.skip(15),
            ),
          ],
        ),
      ],
    );
  }

  static TextStyle _time(Color c) => AppTypography.metadata.copyWith(
    color: c,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

class _Skip extends StatelessWidget {
  const _Skip({required this.icon, required this.label, required this.onTap});

  final ArtIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      pressedScale: .92,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ArtIcon(icon, size: 28, color: p.ink, strokeWidth: 1.3),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '15',
                style: AppTypography.sans(8, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
