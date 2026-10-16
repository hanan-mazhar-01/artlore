import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../home/presentation/widgets/home_style.dart';
import '../../home/presentation/widgets/scan_frame.dart';
import '../../home/presentation/widgets/splash_handoff.dart';
import '../../settings/presentation/settings_controller.dart';

/// The scan frame, then the wordmark settles out of a blur.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2700),
  );

  /// The scanning light over the frame.
  late final _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final _dot = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, .18, curve: Curves.easeOut),
  );
  late final _word = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.29, .87, curve: AppMotion.reveal),
  );
  late final _tagline = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.61, 1, curve: Curves.ease),
  );
  Timer? _next;
  final _frameKey = GlobalKey();
  bool _left = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the painting before the first frame, so the splash never stalls.
    precacheImage(
      ResizeImage.resizeIfNeeded(
        720,
        null,
        mockCatalog[ArtworkIds.starryNight]!.image.provider(),
      ),
      context,
    );
  }

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _scan.repeat();
    _next = Timer(const Duration(milliseconds: 3000), _continue);
  }

  void _continue() {
    if (_left || !mounted) return;
    _left = true;
    final done = ref.read(settingsProvider).onboardingComplete;
    // Going Home: the scan frame flies into the banner.
    if (done) {
      final box = _frameKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.attached) {
        SplashHandoff.begin(
          context,
          from: box.localToGlobal(Offset.zero) & box.size,
          artwork: mockCatalog[ArtworkIds.starryNight]!,
          style: HomeStyle.of(context),
        );
      }
    }
    context.go(done ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _next?.cancel();
    _intro.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ArtScaffold(
      swipeBack: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continue,
        child: Center(
          child: AnimatedBuilder(
            animation: _intro,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SplashFrame(key: _frameKey, appear: _dot.value, scan: _scan),
                const SizedBox(height: 26),
                _Wordmark(t: _word.value),
                const SizedBox(height: 10),
                Opacity(
                  opacity: _tagline.value,
                  child: Text(
                    'A GALLERY IN YOUR HAND',
                    style: AppTypography.sans(
                      10,
                      tracking: .32,
                    ).copyWith(color: p.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The banner's scan frame, rising in where the gold point used to be. It is
/// the same frame the banner shows, and flies there when the splash ends.
class _SplashFrame extends StatelessWidget {
  const _SplashFrame({super.key, required this.appear, required this.scan});

  final double appear;
  final Animation<double> scan;

  static const _width = 150.0;
  static const _height = 144.0;

  @override
  Widget build(BuildContext context) {
    final style = HomeStyle.of(context);
    final artwork = mockCatalog[ArtworkIds.starryNight]!;
    return Opacity(
      opacity: appear,
      child: Transform.scale(
        scale: .9 + .1 * appear,
        child: SizedBox(
          width: _width,
          height: _height,
          child: ScanFrame(
            artwork: artwork,
            style: style,
            scan: scan,
            cropBox: const Size(_height * 2.7, _height),
            backdrop: 1,
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'ArtLore',
      style: AppTypography.serif(
        46,
        weight: FontWeight.w500,
        tracking: .32 - .30 * t,
      ),
    );
    final blur = 6 * (1 - t);
    return Opacity(
      opacity: t,
      child: blur < .05
          ? text
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: text,
            ),
    );
  }
}
