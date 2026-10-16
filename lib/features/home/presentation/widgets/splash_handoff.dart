import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../artwork/domain/artwork.dart';
import 'home_style.dart';
import 'scan_frame.dart';

/// The splash's scan frame flying into Home's banner.
///
/// The splash calls [begin] just before it leaves for Home. That puts a layer
/// above the whole app — the splash's background, wordmark and frame, exactly
/// as they were — so the swap to Home is invisible. The banner reports where
/// its square frame sits ([targetProvider]); the layer then fades the splash
/// away while the frame glides there, and hands over ([landed]).
abstract final class SplashHandoff {
  /// A flight is under way or about to land; the banner is waiting for it.
  static bool active = false;

  /// Set by the banner: where its square frame is, in screen coordinates.
  static Rect? Function()? targetProvider;

  /// Turns true once the frame has landed.
  static final landed = ValueNotifier<bool>(false);

  static OverlayEntry? _entry;

  static void begin(
    BuildContext context, {
    required Rect from,
    required Artwork artwork,
    required HomeStyle style,
  }) {
    _entry?.remove();
    active = true;
    landed.value = false;
    final overlay = Overlay.of(context, rootOverlay: true);
    final background = context.palette.background;
    _entry = OverlayEntry(
      builder: (_) => _Flight(
        from: from,
        artwork: artwork,
        style: style,
        background: background,
      ),
    );
    overlay.insert(_entry!);
  }

  static void _finish() {
    _entry?.remove();
    _entry = null;
    active = false;
    landed.value = true;
  }
}

class _Flight extends StatefulWidget {
  const _Flight({
    required this.from,
    required this.artwork,
    required this.style,
    required this.background,
  });

  final Rect from;
  final Artwork artwork;
  final HomeStyle style;
  final Color background;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with TickerProviderStateMixin {
  late final AnimationController _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  Rect? _target;

  @override
  void initState() {
    super.initState();
    _fly.addStatusListener((s) {
      if (s == AnimationStatus.completed) SplashHandoff._finish();
    });
    _start();
  }

  Future<void> _start() async {
    // Wait for Home to lay out and report where the banner's frame is.
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (mounted && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      final t = SplashHandoff.targetProvider?.call();
      if (t != null) {
        _target = t;
        break;
      }
    }
    if (!mounted) return;
    if (_target == null) {
      SplashHandoff._finish();
      return;
    }
    // A short hold on the splash, then away.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) _fly.forward();
  }

  @override
  void dispose() {
    _fly.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: Listenable.merge([_fly, _scan]),
        builder: (context, _) {
          final move = AppMotion.cardCurve.transform(_fly.value);
          // The splash behind lets go over the first part of the flight.
          final cover =
              1 -
              Curves.easeIn.transform(
                ((_fly.value - .05) / .7).clamp(0.0, 1.0),
              );
          // The target is re-read each frame, so a late layout can't miss.
          final target =
              SplashHandoff.targetProvider?.call() ?? _target ?? widget.from;
          final rect = Rect.lerp(widget.from, target, move)!;
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: cover,
                  child: ColoredBox(color: widget.background),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: widget.from.bottom + 26,
                child: Opacity(
                  opacity: cover,
                  child: Column(
                    children: [
                      Text(
                        'ArtLore',
                        style: AppTypography.serif(
                          46,
                          weight: FontWeight.w500,
                          tracking: .02,
                        ).copyWith(color: p.ink),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'A GALLERY IN YOUR HAND',
                        style: AppTypography.sans(
                          10,
                          tracking: .32,
                        ).copyWith(color: p.muted),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: rect,
                child: ScanFrame(
                  artwork: widget.artwork,
                  style: widget.style,
                  scan: _scan,
                  cropBox: Size(rect.height * 2.7, rect.height),
                  backdrop: 1 - move,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
