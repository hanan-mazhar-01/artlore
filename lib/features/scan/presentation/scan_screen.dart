import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../artwork/presentation/artwork_providers.dart';
import '../../history/presentation/history_controller.dart';
import '../../paywall/presentation/premium_controller.dart';
import 'scan_controller.dart';
import 'widgets/scan_controls.dart';
import 'widgets/scan_viewfinder.dart';

/// The cinematic scanner. Always dark — it stands in for the camera.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _torch = false;

  Future<void> _capture() async {
    final outcome = await ref.read(scanControllerProvider.notifier).capture();
    if (!mounted) return;
    switch (outcome) {
      case CaptureOutcome.proceed:
        context.pushReplacement(AppRoutes.reading);
      case CaptureOutcome.needsPremium:
        context.push(AppRoutes.paywall);
      case CaptureOutcome.busy:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(scanControllerProvider);
    final status = ref.watch(premiumProvider).value;
    final quota = status == null
        ? ''
        : status.isPremium
        ? 'Unlimited scans'
        : '${status.freeScansLeft} free '
              '${status.freeScansLeft == 1 ? 'scan' : 'scans'} left';
    final lastId = ref.watch(
      historyProvider.select((h) => h.value?.firstOrNull?.artworkId),
    );
    final lastCapture = lastId == null
        ? null
        : ref.watch(artworkProvider(lastId)).value?.image;
    final painting = mockCatalog[ArtworkIds.starryNight]!.image;
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) => ArtScaffold(
          background: AppColors.cameraBlack,
          forceLightStatusBar: true,
          body: Stack(
            children: [
              const Positioned.fill(child: _CameraAmbience()),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, context.topInset, 20, 0),
                    child: ScanTopBar(
                      onClose: () => context.backOr(),
                      quota: quota,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: ScanViewfinder(
                          painting: painting,
                          detected: phase != ScanPhase.ready,
                        ),
                      ),
                    ),
                  ),
                  ScanControls(
                    locked: phase != ScanPhase.ready,
                    onCapture: _capture,
                    torchOn: _torch,
                    onTorch: () => setState(() => _torch = !_torch),
                    lastCapture: lastCapture,
                  ),
                  SizedBox(height: math.max(32.0, context.bottomInset + 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Warm wall light falling off into a vignette.
class _CameraAmbience extends StatelessWidget {
  const _CameraAmbience();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.1),
              radius: 1.1,
              colors: [
                AppColors.cameraWarm,
                AppColors.cameraMid,
                AppColors.cameraBlack,
              ],
              stops: [0, .55, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.08),
              radius: 1,
              colors: [Color(0x00000000), Color(0x8C000000)],
              stops: [.4, 1],
            ),
          ),
        ),
      ],
    );
  }
}
