import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';

/// Close button and the free-scan allowance pill.
class ScanTopBar extends StatelessWidget {
  const ScanTopBar({super.key, required this.onClose, required this.quota});

  final VoidCallback onClose;

  /// "3 free scans left" / "Unlimited scans".
  final String quota;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassIconButton(
          icon: ArtIcons.close,
          onTap: onClose,
          semanticLabel: 'Close scanner',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: p.glass,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                quota,
                style: AppTypography.metadata.copyWith(color: p.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Last capture, shutter, torch.
class ScanControls extends StatelessWidget {
  const ScanControls({
    super.key,
    required this.locked,
    required this.onCapture,
    required this.torchOn,
    required this.onTorch,
    this.lastCapture,
  });

  final bool locked;
  final VoidCallback onCapture;
  final bool torchOn;
  final VoidCallback onTorch;
  final ArtImageSource? lastCapture;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.line(.3)),
            ),
            child: lastCapture == null
                ? null
                : ArtImage(lastCapture!, radius: BorderRadius.circular(11)),
          ),
          Tappable(
            onTap: onCapture,
            semanticLabel: 'Capture artwork',
            haptic: HapticKind.medium,
            pressedScale: .92,
            child: AnimatedContainer(
              duration: AppMotion.medium,
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: locked ? p.accent : p.line(.7),
                  width: 1.5,
                ),
              ),
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.inverse,
                  shape: BoxShape.circle,
                ),
                child: ArtIcon(
                  ArtIcons.scan,
                  size: 26,
                  color: p.onInverse,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),
          Tappable(
            onTap: onTorch,
            semanticLabel: torchOn ? 'Turn torch off' : 'Turn torch on',
            pressedScale: .94,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: torchOn ? p.accent : p.line(.2)),
              ),
              child: ArtIcon(
                ArtIcons.flash,
                size: 18,
                color: torchOn ? p.accent : p.ink,
                strokeWidth: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
