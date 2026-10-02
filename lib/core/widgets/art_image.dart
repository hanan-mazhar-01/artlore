import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../media/art_image_source.dart';

/// The one way ArtLore paints artwork.
///
/// * Decodes at the size it is displayed (never the full original).
/// * Clips with CSS-accurate asymmetric radii (arch, leaf, sweep…).
/// * Fades in on first load over a quiet surface tone.
class ArtImage extends StatelessWidget {
  const ArtImage(
    this.source, {
    super.key,
    this.radius,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.shadow,
    this.semanticLabel,
    this.hd = false,
    this.decodeScale = 1,
  });

  final ArtImageSource source;
  final BorderRadius? radius;

  /// CSS `object-position` — see [focal].
  final Alignment alignment;
  final BoxFit fit;
  final List<BoxShadow>? shadow;
  final String? semanticLabel;

  /// Use the high-resolution rendition when one exists.
  final bool hd;

  /// Multiplier for decode size — e.g. when the image is later scaled up.
  final double decodeScale;

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest;
        final r = radius == null ? null : _cssScaled(radius!, size);
        Widget image = Image(
          image: _provider(size, dpr),
          fit: fit,
          alignment: alignment,
          width: size.width.isFinite ? size.width : null,
          height: size.height.isFinite ? size.height : null,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          semanticLabel: semanticLabel,
          excludeFromSemantics: semanticLabel == null,
          frameBuilder: _fadeIn,
          errorBuilder: (_, _, _) => ColoredBox(color: surface),
        );
        image = DecoratedBox(
          decoration: BoxDecoration(color: surface, borderRadius: r),
          child: image,
        );
        if (r != null) image = ClipRRect(borderRadius: r, child: image);
        if (shadow == null) return image;
        return DecoratedBox(
          decoration: BoxDecoration(borderRadius: r, boxShadow: shadow),
          child: image,
        );
      },
    );
  }

  ImageProvider _provider(Size size, double dpr) {
    final base = source.provider(hd: hd);
    if (!size.width.isFinite || !size.height.isFinite) return base;
    // Width needed to cover the box at this aspect, in physical pixels.
    final needed = math.max(size.width, size.height * source.aspect);
    final px = (needed * dpr * decodeScale).round();
    return ResizeImage.resizeIfNeeded(px, null, base);
  }

  static Widget _fadeIn(
    BuildContext context,
    Widget child,
    int? frame,
    bool sync,
  ) {
    if (sync) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      child: child,
    );
  }

  /// Browsers shrink radii that overflow a side; Flutter clips need the same
  /// treatment for shapes like `170px 0 0 6px` on narrow boxes.
  static BorderRadius _cssScaled(BorderRadius r, Size s) {
    if (!s.width.isFinite || !s.height.isFinite) return r;
    double f = 1;
    void fit(double a, double b, double side) {
      if (a + b > side && a + b > 0) f = math.min(f, side / (a + b));
    }

    fit(r.topLeft.x, r.topRight.x, s.width);
    fit(r.bottomLeft.x, r.bottomRight.x, s.width);
    fit(r.topLeft.y, r.bottomLeft.y, s.height);
    fit(r.topRight.y, r.bottomRight.y, s.height);
    return f == 1 ? r : r * f;
  }
}
