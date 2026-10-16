import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';

/// The header: back, the title, the torch and the camera switch.
class ScanHeader extends StatelessWidget {
  const ScanHeader({
    super.key,
    required this.onBack,
    required this.onFlip,
    required this.torchOn,
    required this.onTorch,
  });

  final VoidCallback onBack;
  final VoidCallback onFlip;
  final bool torchOn;
  final VoidCallback onTorch;

  Widget _round(
    BuildContext context,
    ArtIconData icon,
    VoidCallback onTap,
    String label,
  ) {
    final dark = context.isDark;
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      pressedScale: .92,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF2A2826) : const Color(0xFFF3EDE2),
          shape: BoxShape.circle,
          border: dark ? Border.all(color: const Color(0x1FFFFFFF)) : null,
        ),
        child: ArtIcon(
          icon,
          size: 18,
          color: dark ? const Color(0xFFF5EFE5) : const Color(0xFF2B2420),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _round(context, ArtIcons.chevronLeft, onBack, 'Back'),
        Expanded(
          child: Text(
            'Scan a Painting',
            textAlign: TextAlign.center,
            style: AppTypography.sans(18, weight: FontWeight.w700).copyWith(
              color: const Color(0xFFF5EFE5),
              decoration: TextDecoration.none,
              shadows: const [Shadow(color: Color(0x99000000), blurRadius: 8)],
            ),
          ),
        ),
        // The torch: dark glass with a slashed bolt when off; lit gold, with
        // a glow, when on.
        Tappable(
          onTap: onTorch,
          semanticLabel: torchOn ? 'Turn torch off' : 'Turn torch on',
          pressedScale: .92,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: torchOn
                  ? const Color(0xFFE2C27F)
                  : const Color(0xFF1D1A17),
              shape: BoxShape.circle,
              boxShadow: torchOn
                  ? const [
                      BoxShadow(
                        color: Color(0x99E2C27F),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ArtIcon(
                  ArtIcons.flash,
                  size: 19,
                  color: torchOn
                      ? const Color(0xFF2B2420)
                      : const Color(0xFFF5EFE5),
                  strokeWidth: 1.7,
                ),
                if (!torchOn)
                  Transform.rotate(
                    angle: -.785,
                    child: Container(
                      width: 26,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _round(context, ArtIcons.flip, onFlip, 'Switch camera'),
      ],
    );
  }
}

/// The light tray under the viewfinder: zoom chips, a ruler, and the row with
/// the gallery, the shutter and the camera switch.
class ScanTray extends StatelessWidget {
  const ScanTray({
    super.key,
    required this.zoom,
    required this.onZoomChanged,
    required this.locked,
    required this.busy,
    required this.onCapture,
    required this.onGallery,
    required this.ratioLabel,
    required this.onRatio,
    this.lastCapture,
    required this.bottomInset,
  });

  final double zoom;
  final ValueChanged<double> onZoomChanged;
  final bool locked;
  final bool busy;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final String ratioLabel;
  final VoidCallback onRatio;
  final ArtImageSource? lastCapture;
  final double bottomInset;

  static const levels = [1.0, 2.0, 3.0];
  static const _gold = Color(0xFFC9A45C);

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final tray = dark ? const Color(0xFF1B1B1A) : const Color(0xFFF3EDE2);
    final ink = dark ? const Color(0xFFF5EFE5) : const Color(0xFF2B2420);
    final chip = dark ? const Color(0xFF2B2A28) : const Color(0xFFE6DECE);
    final chipInk = dark ? const Color(0xFFB8AEA0) : const Color(0xFF6C6155);
    final chipOnInk = dark ? const Color(0xFFE0C17E) : const Color(0xFF7A5A1A);
    final round = dark ? const Color(0xFFF5EFE5) : const Color(0xFF1D1A17);
    final roundInk = dark ? const Color(0xFF151515) : const Color(0xFFF5EFE5);
    var selected = -1;
    for (var i = 0; i < levels.length; i++) {
      if ((levels[i] - zoom).abs() < .15) selected = i;
    }
    return Container(
      padding: EdgeInsets.fromLTRB(26, 18, 26, bottomInset + 16),
      decoration: BoxDecoration(
        color: tray,
        border: dark
            ? const Border(top: BorderSide(color: Color(0x1FFFFFFF)))
            : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 40,
            offset: Offset(0, -18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < levels.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Tappable(
                  onTap: () {
                    if (i == selected) return;
                    Haptics.play(HapticKind.selection);
                    onZoomChanged(levels[i]);
                  },
                  semanticLabel: 'Zoom ${levels[i].round()}x',
                  pressedScale: .94,
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    constraints: const BoxConstraints(minWidth: 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected
                          ? _gold.withValues(alpha: .28)
                          : chip,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: i == selected ? _gold : const Color(0x00000000),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${levels[i].round()}×',
                      style: AppTypography.sans(14, weight: FontWeight.w700)
                          .copyWith(
                            color: i == selected ? chipOnInk : chipInk,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // The ruler is a slider: drag it, or tap anywhere on it.
          LayoutBuilder(
            builder: (context, box) {
              void setFrom(double dx) {
                final t = ((dx - 12) / (box.maxWidth - 24)).clamp(0.0, 1.0);
                final z = 1 + (levels.last - 1) * t;
                if ((z - zoom).abs() > .01) onZoomChanged(z);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => setFrom(d.localPosition.dx),
                onHorizontalDragStart: (d) => setFrom(d.localPosition.dx),
                onHorizontalDragUpdate: (d) => setFrom(d.localPosition.dx),
                child: SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _RulerPainter(
                      ((zoom - 1) / (levels.last - 1)).clamp(0.0, 1.0),
                      ink,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tappable(
                onTap: busy ? null : onGallery,
                semanticLabel: 'Scan from photos',
                pressedScale: .92,
                child: Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF3A3835)
                        : const Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: lastCapture != null
                        ? ArtImage(lastCapture!)
                        : ColoredBox(
                            color: chip,
                            child: Center(
                              child: ArtIcon(
                                ArtIcons.photos,
                                size: 22,
                                color: ink,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Tappable(
                onTap: busy ? null : onCapture,
                semanticLabel: 'Capture artwork',
                // No buzz on the press: it would shake the phone as the photo
                // is taken. The screen buzzes once the shot is done.
                haptic: HapticKind.none,
                pressedScale: .92,
                child: AnimatedContainer(
                  duration: AppMotion.medium,
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _gold.withValues(alpha: (locked || busy) ? 1 : .5),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 74,
                    height: 74,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE8CD8D), Color(0xFFC29A48)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xB3A87E30),
                          blurRadius: 24,
                          spreadRadius: -6,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Color(0xFFFFFFFF),
                            ),
                          )
                        : const ArtIcon(
                            ArtIcons.camera,
                            size: 30,
                            color: Color(0xFFFFFFFF),
                            strokeWidth: 1.8,
                          ),
                  ),
                ),
              ),
              Tappable(
                onTap: busy ? null : onRatio,
                semanticLabel: 'Frame ratio $ratioLabel',
                pressedScale: .92,
                child: Container(
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: round,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: AppMotion.fast,
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(
                        scale: Tween(begin: .8, end: 1.0).animate(a),
                        child: c,
                      ),
                    ),
                    child: Text(
                      ratioLabel,
                      key: ValueKey(ratioLabel),
                      style: AppTypography.sans(15, weight: FontWeight.w700)
                          .copyWith(
                            color: roundInk,
                            decoration: TextDecoration.none,
                          ),
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

/// Fine ticks across the tray, fading at both ends, with a gold marker that
/// slides to the chosen zoom.
class _RulerPainter extends CustomPainter {
  const _RulerPainter(this.t, this.ink);

  final double t;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final tick = Paint()
      ..color = ink
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const step = 20.0;
    final n = (size.width / step).floor();
    final x0 = (size.width - n * step) / 2;
    for (var i = 0; i <= n; i++) {
      final x = x0 + i * step;
      final edge = (x / size.width - .5).abs() * 2; // 0 centre → 1 edge
      final fade = edge < .72 ? 1.0 : ((1 - edge) / .28).clamp(0.0, 1.0);
      tick.color = ink.withValues(alpha: .32 * fade);
      canvas.drawLine(Offset(x, 15), Offset(x, 27), tick);
    }
    final marker = Paint()
      ..color = const Color(0xFFA9843A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final mx = 12 + (size.width - 24) * t;
    canvas.drawLine(Offset(mx, 11), Offset(mx, 33), marker);
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.t != t || old.ink != ink;
}
