import 'dart:typed_data';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart' show PhotoManager;

import '../../../core/extensions/context_x.dart';
import '../../../core/media/image_crop.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/tappable.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../artwork/data/dynamic_artwork_storage.dart';
import '../../artwork/presentation/artwork_providers.dart';
import '../../history/presentation/history_controller.dart';
import '../../../core/media/art_image_source.dart';
import '../../home/presentation/home_providers.dart';
import 'ai_consent.dart';
import 'scan_controller.dart';
import 'scan_launcher.dart';
import 'widgets/scan_camera_feed.dart';
import 'widgets/scan_tray.dart';
import 'widgets/scan_viewfinder.dart';

/// The cinematic scanner. Always dark — it stands in for the camera.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  /// The visitor said no to the camera: say so, and offer the Settings.
  bool _cameraDenied = false;

  CameraController? _cameraController;
  bool _torch = false;
  double _zoom = 1.0;
  _FrameRatio _ratio = _FrameRatio.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The first time the camera opens, the agreement comes first, and the
    // camera does not start until it is given. Leaving the choice leaves the
    // screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _agreeThenStart());
  }

  Future<void> _agreeThenStart() async {
    if (!mounted) return;
    final agreed = await ensureAiConsent(context, ref);
    if (!mounted) return;
    if (agreed) {
      _initCamera();
      askPhotoAccessOnce(ref);
    } else {
      context.backOr();
    }
  }

  CameraLensDirection _lens = CameraLensDirection.back;

  /// Swaps between the back and the front camera.
  /// Tap to focus where the visitor touched the frame.
  Future<void> _focusAt(Offset point) async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    try {
      await c.setFocusPoint(point);
      await c.setExposurePoint(point);
    } catch (_) {}
  }

  Future<void> _flip() async {
    _lens = _lens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final old = _cameraController;
    setState(() {
      _cameraController = null;
      _zoom = 1.0;
      _torch = false;
    });
    await old?.dispose();
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;
      final chosen = cameras.firstWhere(
        (c) => c.lensDirection == _lens,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        chosen,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _cameraController = ctrl;
        _cameraDenied = false;
      });
    } on CameraException catch (e) {
      if (mounted && e.code.startsWith('CameraAccess')) {
        setState(() => _cameraDenied = true);
      }
    } catch (_) {
      // Graceful fallback for environments without camera
    }
  }

  /// Back from the phone's Settings: if the camera was refused, try again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _cameraDenied &&
        _cameraController == null) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  final _feedKey = GlobalKey();
  final _frameKey = GlobalKey();

  bool _busy = false;
  bool _showFlash = false;
  String? _capturedPhotoId;

  Future<void> _capture() async {
    if (_busy) return;
    // The photo goes to an AI service: ask first, once.
    if (!await ensureAiConsent(context, ref)) return;
    if (!mounted) return;
    setState(() {
      _busy = true;
      _showFlash = true;
    });
    Haptics.play(HapticKind.success);

    // Trigger shutter flash
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _showFlash = false);
    });

    ref.read(scanControllerProvider.notifier).beginCapturing();

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Freeze preview immediately so live recording stops
        await _cameraController!.pausePreview();
      } catch (_) {}

      try {
        final xFile = await _cameraController!.takePicture();
        final rawBytes = await xFile.readAsBytes();
        // Only what lay between the four corners goes on to be scanned.
        final feed = _feedKey.currentContext?.findRenderObject() as RenderBox?;
        final frame =
            _frameKey.currentContext?.findRenderObject() as RenderBox?;
        Uint8List bytes;
        if (feed != null && frame != null && feed.hasSize && frame.hasSize) {
          final origin = feed.localToGlobal(Offset.zero);
          final topLeft = frame.localToGlobal(Offset.zero) - origin;
          debugPrint(
            'SCANCROP view=${feed.size} frame=${topLeft & frame.size} raw=${rawBytes.length}',
          );
          bytes = await cropToFrame(
            rawBytes,
            viewSize: feed.size,
            frame: topLeft & frame.size,
          );
        } else {
          bytes = rawBytes;
        }
        ref.read(pendingFrameBytesProvider.notifier).state = bytes;
        _capturedPhotoId = 'camera-${DynamicArtworkStorage.hashOf(bytes)}';
      } catch (e) {
        // Never reuse the previous scan's picture.
        ref.read(pendingFrameBytesProvider.notifier).state = null;
        _capturedPhotoId = null;
      }
    }
    await _resolveCapture();
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _resolveCapture() async {
    final outcome = await ref.read(scanControllerProvider.notifier).capture();
    if (!mounted) return;
    switch (outcome) {
      case CaptureOutcome.proceed:
        final id = _capturedPhotoId;
        if (mounted) {
          context.pushReplacement(
            id == null ? AppRoutes.reading : AppRoutes.readingPhoto(id),
          );
        }
      case CaptureOutcome.needsAccount:
        try {
          await _cameraController?.resumePreview();
        } catch (_) {}
        ref.read(scanControllerProvider.notifier).resetToReady();
        if (!mounted) return;
        final unlocked = await context.push<bool>(AppRoutes.accountWall);
        if (unlocked == true && mounted) {
          ref.read(scanControllerProvider.notifier).beginCapturing();
          await _resolveCapture();
        } else if (mounted) {
          try {
            await _cameraController?.resumePreview();
          } catch (_) {}
        }
      case CaptureOutcome.needsPremium:
        try {
          await _cameraController?.resumePreview();
        } catch (_) {}
        ref.read(scanControllerProvider.notifier).resetToReady();
        if (!mounted) return;
        await context.push(AppRoutes.paywall);
        if (mounted) {
          try {
            await _cameraController?.resumePreview();
          } catch (_) {}
        }
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
    final lastScanned = lastId == null
        ? null
        : ref.watch(artworkProvider(lastId)).value?.image;
    // The gallery button shows the newest photo on the phone, when access is
    // given; until then, the last painting scanned.
    final devicePhotos = ref.watch(latestPhotoProvider).value;
    final lastCapture = (devicePhotos != null && devicePhotos.isNotEmpty)
        ? ArtImageSource.memory(devicePhotos.first)
        : lastScanned;

    final isDark = context.isDark;

    return ArtScaffold(
      background: Colors.transparent,
      forceLightStatusBar: isDark,
      body: Stack(
        children: [
          // The live camera fills the whole screen, unblurred; the frame
          // marks the part that is scanned. A soft shade at the top and the
          // bottom keeps the header and the tray readable over it.
          Positioned.fill(
            child: KeyedSubtree(
              key: _feedKey,
              child: ScanCameraFeed(controller: _cameraController),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x8C000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x59000000),
                    ],
                    stops: [0, .22, .7, 1],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, context.topInset + 6, 16, 0),
                child: ScanHeader(
                  onBack: () => context.backOr(),
                  onFlip: _flip,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: ScanViewfinder(
                        frameKey: _frameKey,
                        detected: phase == ScanPhase.detected,
                        scanning: phase == ScanPhase.capturing,
                        ratio: _ratio.value,
                        onFocus: _focusAt,
                      ),
                    ),
                    if (_cameraDenied && _cameraController == null)
                      const _CameraOffNotice(),
                  ],
                ),
              ),
              ScanTray(
                zoom: _zoom,
                onZoomChanged: (val) async {
                  setState(() => _zoom = val);
                  if (_cameraController != null &&
                      _cameraController!.value.isInitialized) {
                    try {
                      final min = await _cameraController!.getMinZoomLevel();
                      final max = await _cameraController!.getMaxZoomLevel();
                      await _cameraController!.setZoomLevel(
                        val.clamp(min, max),
                      );
                    } catch (_) {}
                  }
                },
                locked:
                    phase == ScanPhase.detected || phase == ScanPhase.capturing,
                busy: _busy || phase == ScanPhase.capturing,
                onCapture: _capture,
                onGallery: () => ScanLauncher.fromPhotos(context, ref),
                ratioLabel: _ratio.label,
                onRatio: () {
                  Haptics.play(HapticKind.selection);
                  setState(
                    () => _ratio = _FrameRatio
                        .values[(_ratio.index + 1) % _FrameRatio.values.length],
                  );
                },
                lastCapture: lastCapture,
                bottomInset: math.max(10.0, context.bottomInset),
              ),
            ],
          ),
          // White shutter flash overlay
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: _showFlash ? 0.85 : 0.0,
              child: const ColoredBox(
                color: Colors.white,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The shapes the frame can take; the button in the tray steps through them.
enum _FrameRatio {
  auto('Auto', ScanViewfinder.autoRatio),
  threeFour('3:4', 3 / 4),
  fourFive('4:5', 4 / 5),
  square('1:1', 1),
  twoThree('2:3', 2 / 3);

  const _FrameRatio(this.label, this.value);
  final String label;
  final double value;
}

/// Shown over the viewfinder when the camera has been refused.
class _CameraOffNotice extends StatelessWidget {
  const _CameraOffNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xF2F3EDE2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Camera access is off',
            textAlign: TextAlign.center,
            style: AppTypography.sans(16, weight: FontWeight.w700).copyWith(
              color: const Color(0xFF2B2420),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Allow the camera in Settings to scan a painting, or scan one '
            'from your photos.',
            textAlign: TextAlign.center,
            style: AppTypography.sans(13, height: 1.45).copyWith(
              color: const Color(0xFF6C6155),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),
          Tappable(
            onTap: () => PhotoManager.openSetting(),
            semanticLabel: 'Open Settings',
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1A17),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Text(
                'Open Settings',
                style: AppTypography.sans(14, weight: FontWeight.w700).copyWith(
                  color: const Color(0xFFF5EFE5),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
