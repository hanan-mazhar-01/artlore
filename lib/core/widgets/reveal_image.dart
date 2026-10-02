import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../media/art_image_source.dart';
import '../theme/app_motion.dart';
import '../utils/color_filters.dart';
import 'art_image.dart';

/// `alReveal` — the artwork surfaces from darkness: blur 22 → 0,
/// brightness .25 → 1, saturation .3 → 1, scale 1.06 → 1.
class RevealImage extends StatefulWidget {
  const RevealImage(
    this.source, {
    super.key,
    this.duration = const Duration(seconds: 2),
    this.curve = Curves.ease,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  final ArtImageSource source;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;
  final String? semanticLabel;

  @override
  State<RevealImage> createState() => _RevealImageState();
}

class _RevealImageState extends State<RevealImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: widget.curve,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed) return;
    if (AppMotion.reduced(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = RepaintBoundary(
      child: ArtImage(
        widget.source,
        alignment: widget.alignment,
        semanticLabel: widget.semanticLabel,
      ),
    );
    return ClipRect(
      child: AnimatedBuilder(
        animation: _t,
        child: image,
        builder: (context, child) {
          final t = _t.value;
          if (t >= 1) return child!;
          final sigma = 22 * (1 - t);
          return Transform.scale(
            scale: 1.06 - .06 * t,
            child: ColorFiltered(
              colorFilter: ColorFilters.grade(
                saturation: .3 + .7 * t,
                brightness: .25 + .75 * t,
              ),
              child: sigma < .05
                  ? child
                  : ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: sigma,
                        sigmaY: sigma,
                      ),
                      child: child,
                    ),
            ),
          );
        },
      ),
    );
  }
}
