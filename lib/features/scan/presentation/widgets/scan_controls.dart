import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';

export 'scan_zoom_slider.dart';

/// Close button and the flash toggle in the top bar.
class ScanTopBar extends StatelessWidget {
  const ScanTopBar({
    super.key,
    required this.onClose,
    required this.torchOn,
    required this.onTorch,
  });

  final VoidCallback onClose;
  final bool torchOn;
  final VoidCallback onTorch;

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
        Tappable(
          onTap: onTorch,
          semanticLabel: torchOn ? 'Turn torch off' : 'Turn torch on',
          pressedScale: .92,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: torchOn ? p.accent.withValues(alpha: .2) : p.glass,
              shape: BoxShape.circle,
              border: Border.all(
                color: torchOn ? p.accent : p.line(.3),
                width: 1.2,
              ),
              boxShadow: torchOn
                  ? [
                      BoxShadow(
                        color: p.accent.withValues(alpha: .35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ArtIcon(
              ArtIcons.flash,
              size: 19,
              color: torchOn ? p.accent : p.ink,
              strokeWidth: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Gallery picker and the shutter.
class ScanControls extends StatelessWidget {
  const ScanControls({
    super.key,
    required this.locked,
    required this.onCapture,
    required this.onGallery,
    this.lastCapture,
    this.busy = false,
  });

  final bool locked;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final ArtImageSource? lastCapture;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tappable(
            onTap: busy ? null : onGallery,
            semanticLabel: 'Scan from photos',
            pressedScale: .92,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: p.glass,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.line(.3)),
              ),
              child: lastCapture != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: ArtImage(lastCapture!),
                    )
                  : Center(
                      child: ArtIcon(
                        ArtIcons.photos,
                        size: 22,
                        color: p.ink,
                        strokeWidth: 1.5,
                      ),
                    ),
            ),
          ),
          Tappable(
            onTap: busy ? null : onCapture,
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
                  color: (locked || busy) ? p.accent : p.line(.7),
                  width: 1.8,
                ),
              ),
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
                child: busy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFFFFFFFF),
                        ),
                      )
                    : const ArtIcon(
                        ArtIcons.camera,
                        size: 30,
                        color: AppColors.night,
                        strokeWidth: 1.9,
                      ),
              ),
            ),
          ),
          // Keeps the shutter centred, balancing the gallery button.
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}
