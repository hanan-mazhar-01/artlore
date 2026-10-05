import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/media/art_image_source.dart';
import '../../../../core/widgets/art_image.dart';

/// Renders either the active live camera preview or a fallback image.
class ScanCameraFeed extends StatelessWidget {
  const ScanCameraFeed({
    super.key,
    this.controller,
    this.fallbackPainting,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final CameraController? controller;
  final ArtImageSource? fallbackPainting;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (controller != null && controller!.value.isInitialized) {
      final size = controller!.value.previewSize;
      if (size != null) {
        content = ClipRect(
          child: FittedBox(
            fit: fit,
            child: SizedBox(
              width: size.height,
              height: size.width,
              child: CameraPreview(controller!),
            ),
          ),
        );
      } else {
        content = CameraPreview(controller!);
      }
    } else if (fallbackPainting != null) {
      content = ArtImage(fallbackPainting!, radius: borderRadius);
    } else {
      content = Container(
        color: const Color(0xFF0F0E0D),
        child: const Center(
          child: Icon(
            Icons.camera_alt_outlined,
            color: Color(0x33FFFFFF),
            size: 40,
          ),
        ),
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    return content;
  }
}

/// Atmospheric full-screen background: blurred live camera stream
/// with museum dark tint and spotlight beam support.
class ScanBlurredCameraBackground extends StatelessWidget {
  const ScanBlurredCameraBackground({
    super.key,
    this.controller,
    this.torchOn = false,
  });

  final CameraController? controller;
  final bool torchOn;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark
        ? Colors.black.withValues(alpha: .55)
        : Colors.white.withValues(alpha: .68);
    final vignetteEdge = isDark
        ? const Color(0x99000000)
        : const Color(0x22000000);
    final fallbackColors = isDark
        ? const [Color(0xFF221F1C), Color(0xFF141312), Color(0xFF0A0A09)]
        : const [Color(0xFFFBF9F5), Color(0xFFF2EFE9), Color(0xFFE5E0D7)];
    final beamColor = isDark
        ? const Color(0x40FFF1D0)
        : const Color(0x55FFEAA0);

    if (controller != null && controller!.value.isInitialized) {
      final size = controller!.value.previewSize;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (size != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: size.height,
                height: size.width,
                child: CameraPreview(controller!),
              ),
            ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ColoredBox(color: overlayColor),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.08),
                radius: 1.1,
                colors: [const Color(0x00000000), vignetteEdge],
                stops: const [.35, 1],
              ),
            ),
          ),
          if (torchOn)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -.06),
                  radius: .9,
                  colors: [beamColor, const Color(0x00000000)],
                  stops: const [0, 1],
                ),
              ),
            ),
        ],
      );
    }

    // Fallback when camera is not ready
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -.1),
              radius: 1.1,
              colors: fallbackColors,
              stops: const [0, .55, 1],
            ),
          ),
        ),
        if (torchOn)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.06),
                radius: .9,
                colors: [beamColor, const Color(0x00000000)],
                stops: const [0, 1],
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -.08),
              radius: 1,
              colors: [const Color(0x00000000), vignetteEdge],
              stops: const [.4, 1],
            ),
          ),
        ),
      ],
    );
  }
}
