import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/media/image_crop.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../artwork/data/dynamic_artwork_storage.dart';
import '../../artwork/presentation/artwork_providers.dart';
import '../../history/presentation/history_controller.dart';
import 'scan_controller.dart';
import 'scan_launcher.dart';
import 'widgets/scan_camera_feed.dart';
import 'widgets/scan_controls.dart';
import 'widgets/scan_viewfinder.dart';

/// The cinematic scanner. Always dark — it stands in for the camera.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _cameraController;
  bool _torch = false;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() => _cameraController = ctrl);
    } catch (_) {
      // Graceful fallback for environments without camera
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  bool _busy = false;
  String? _capturedPhotoId;

  Future<void> _capture() async {
    if (_busy) return;
    _busy = true;
    // Freeze the viewfinder the instant the shutter is tapped — taking and
    // cropping the photo below takes real time, and the live feed should
    // not look like it's still running while that happens.
    ref.read(scanControllerProvider.notifier).beginCapturing();

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final xFile = await _cameraController!.takePicture();
        final rawBytes = await xFile.readAsBytes();
        final bytes = await cropToAspectRatio(
          rawBytes,
          ScanViewfinder.aspectRatio,
        );
        ref.read(pendingFrameBytesProvider.notifier).state = bytes;
        // Content-derived, not a constant — otherwise every live capture
        // would share the same analysisControllerProvider family entry and
        // a later scan could surface an earlier one's cached result.
        _capturedPhotoId = 'camera-${DynamicArtworkStorage.hashOf(bytes)}';
      } catch (_) {
        _capturedPhotoId = null;
      }
    }
    await _resolveCapture();
    _busy = false;
  }

  Future<void> _resolveCapture() async {
    final outcome = await ref.read(scanControllerProvider.notifier).capture();
    if (!mounted) return;
    switch (outcome) {
      case CaptureOutcome.proceed:
        final id = _capturedPhotoId;
        context.pushReplacement(
          id == null ? AppRoutes.reading : AppRoutes.readingPhoto(id),
        );
      case CaptureOutcome.needsAccount:
        ref.read(scanControllerProvider.notifier).resetToDetected();
        final unlocked = await context.push<bool>(AppRoutes.accountWall);
        if (unlocked == true && mounted) {
          ref.read(scanControllerProvider.notifier).beginCapturing();
          await _resolveCapture();
        }
      case CaptureOutcome.needsPremium:
        ref.read(scanControllerProvider.notifier).resetToDetected();
        context.push(AppRoutes.paywall);
      case CaptureOutcome.busy:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(scanControllerProvider);
    final lastId = ref.watch(
      historyProvider.select((h) => h.value?.firstOrNull?.artworkId),
    );
    final lastCapture = lastId == null
        ? null
        : ref.watch(artworkProvider(lastId)).value?.image;

    final isDark = context.isDark;

    return ArtScaffold(
      background: Colors.transparent,
      forceLightStatusBar: isDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: ScanBlurredCameraBackground(
              controller: _cameraController,
              torchOn: _torch,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, context.topInset, 20, 0),
                child: ScanTopBar(
                  onClose: () => context.backOr(),
                  torchOn: _torch,
                  onTorch: () async {
                    final next = !_torch;
                    setState(() => _torch = next);
                    if (_cameraController != null &&
                        _cameraController!.value.isInitialized) {
                      try {
                        await _cameraController!.setFlashMode(
                          next ? FlashMode.torch : FlashMode.off,
                        );
                      } catch (_) {}
                    }
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: ScanViewfinder(
                      cameraController: _cameraController,
                      detected: phase != ScanPhase.ready,
                      scanning: phase == ScanPhase.capturing,
                      zoom: _zoom,
                    ),
                  ),
                ),
              ),
              ScanZoomControl(
                zoom: _zoom,
                onZoomChanged: (val) async {
                  setState(() => _zoom = val);
                  if (_cameraController != null &&
                      _cameraController!.value.isInitialized) {
                    try {
                      final min = await _cameraController!.getMinZoomLevel();
                      final max = await _cameraController!.getMaxZoomLevel();
                      await _cameraController!.setZoomLevel(val.clamp(min, max));
                    } catch (_) {}
                  }
                },
              ),
              const SizedBox(height: 12),
              ScanControls(
                locked: phase != ScanPhase.ready,
                onCapture: _capture,
                onGallery: () => ScanLauncher.fromPhotos(context, ref),
                onResetZoom: () async {
                  setState(() => _zoom = 1.0);
                  if (_cameraController != null &&
                      _cameraController!.value.isInitialized) {
                    try {
                      await _cameraController!.setZoomLevel(1.0);
                    } catch (_) {}
                  }
                },
                zoom: _zoom,
                lastCapture: lastCapture,
              ),
              SizedBox(height: math.max(28.0, context.bottomInset + 14)),
            ],
          ),
        ],
      ),
    );
  }
}
