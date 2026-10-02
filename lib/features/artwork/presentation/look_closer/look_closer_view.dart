import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/haptics.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import 'look_closer_camera.dart';
import 'look_closer_canvas.dart';
import 'look_closer_screen.dart';
import 'look_closer_sheets.dart';

/// Owns the camera: tap a marker and the canvas glides to it; pinch and pan
/// freely at any time. Zoom/pan never rebuild this widget — only the
/// transformation controller and the pins update.
class LookCloserView extends ConsumerStatefulWidget {
  const LookCloserView({
    super.key,
    required this.artwork,
    required this.details,
  });

  final Artwork artwork;
  final List<ArtworkDetail> details;

  @override
  ConsumerState<LookCloserView> createState() => _LookCloserViewState();
}

class _LookCloserViewState extends ConsumerState<LookCloserView>
    with TickerProviderStateMixin {
  final _tc = TransformationController();
  final _zoom = ValueNotifier<double>(1);
  late final _glide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..addListener(_onGlide);
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  Matrix4Tween? _move;
  LookCloserCamera? _camera;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _tc.addListener(() => _zoom.value = _tc.value.getMaxScaleOnAxis());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _glide.dispose();
    _pulse.dispose();
    _tc.dispose();
    _zoom.dispose();
    super.dispose();
  }

  void _onGlide() {
    final t = AppMotion.glide.transform(_glide.value);
    _tc.value = _move!.transform(t);
  }

  void _glideTo(Matrix4 target) {
    _move = Matrix4Tween(begin: _tc.value.clone(), end: target);
    if (AppMotion.reduced(context)) {
      _tc.value = target;
    } else {
      _glide.forward(from: 0);
    }
  }

  void _pick(int i) {
    Haptics.play(HapticKind.selection);
    final d = widget.details[i];
    setState(() => _selected = i);
    _glideTo(_camera!.focus(d.x, d.y));
  }

  void _reset() {
    setState(() => _selected = null);
    _glideTo(_camera!.overview());
  }

  Matrix4 _frame(LookCloserCamera camera) {
    final i = _selected;
    if (i == null) return camera.overview();
    return camera.focus(widget.details[i].x, widget.details[i].y);
  }

  void _step(int delta) {
    final n = widget.details.length;
    _pick(((_selected ?? 0) + delta + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final showMarkers = ref.watch(
      settingsProvider.select((s) => s.showMarkers),
    );
    return LayoutBuilder(
      builder: (context, c) {
        final viewport = Size(c.maxWidth, math.max(380, c.maxHeight - 224));
        final camera = LookCloserCamera(
          viewport: viewport,
          aspect: widget.artwork.image.aspect,
        );
        if (_camera == null) {
          _camera = camera;
          _tc.value = camera.overview();
        } else if (_camera!.viewport != viewport) {
          // Re-frame after layout so listeners never fire mid-build.
          _camera = camera;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _tc.value = _frame(camera);
          });
        }
        final selected = _selected;
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: viewport.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LookCloserCanvas(
                    artwork: widget.artwork,
                    details: widget.details,
                    camera: camera,
                    controller: _tc,
                    zoom: _zoom,
                    pulse: _pulse,
                    selected: selected,
                    showAllMarkers: showMarkers,
                    onPick: _pick,
                    onInteractionStart: _glide.stop,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 120,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [p.deep.withValues(alpha: 0), p.deep],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: context.topInset,
              left: 20,
              right: 20,
              child: LookCloserTopBar(onReset: _reset),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.sheet,
                transitionBuilder: (child, a) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, .35),
                    end: Offset.zero,
                  ).animate(a),
                  child: FadeTransition(opacity: a, child: child),
                ),
                child: selected == null
                    ? LookCloserIntro(
                        key: const ValueKey('intro'),
                        count: widget.details.length,
                        onBegin: () => _pick(0),
                      )
                    : DetailSheet(
                        key: const ValueKey('sheet'),
                        detail: widget.details[selected],
                        index: selected,
                        total: widget.details.length,
                        onClose: _reset,
                        onPrevious: () => _step(-1),
                        onNext: () => _step(1),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
