import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import 'cover_flight.dart';
import 'hanging_frames.dart';
import 'home_style.dart';
import 'photo_liftoff.dart';

/// Two cards under the hero: scan from the photo library (light) and the
/// visitor's collection (dark, with its first few covers).
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onScanPhotos,
    required this.onCollection,
    required this.savedCount,
    this.thumbs = const [],
    this.latestPhotos = const [],
  });

  /// Opens the photo picker; completes when it closes.
  final Future<void> Function() onScanPhotos;
  final VoidCallback onCollection;

  /// Number of saved works, or null while it loads.
  final int? savedCount;

  /// Up to three cover images from the collection, newest first.
  final List<ArtImageSource> thumbs;

  /// The two newest photos in the phone's library (newest first), if access
  /// was granted.
  final List<Uint8List> latestPhotos;

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final count = savedCount ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: _PhotosCard(
              style: s,
              onTap: onScanPhotos,
              photos: latestPhotos,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CollectionCard(
              style: s,
              onTap: onCollection,
              thumbs: thumbs.take(3).toList(),
              label: count > 0
                  ? '$count ${count == 1 ? 'work' : 'works'} saved'
                  : 'Start your collection',
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosCard extends StatefulWidget {
  const _PhotosCard({
    required this.style,
    required this.onTap,
    required this.photos,
  });

  final HomeStyle style;
  final Future<void> Function() onTap;
  final List<Uint8List> photos;

  @override
  State<_PhotosCard> createState() => _PhotosCardState();
}

class _PhotosCardState extends State<_PhotosCard> {
  final _frontKey = GlobalKey();
  final _backKey = GlobalKey();

  /// The pair has been released and is floating up on the overlay.
  bool _away = false;
  bool _busy = false;

  Offset? _centerOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  Future<void> _open() async {
    if (_busy) return;
    _busy = true;
    final front = _centerOf(_frontKey);
    final back = _centerOf(_backKey);
    if (front != null && back != null && !AppMotion.reduced(context)) {
      final h = MediaQuery.sizeOf(context).height;
      final photos = widget.photos;
      // The two cards leave the container, drifting apart as they rise…
      PhotoLiftOff.play(
        context,
        style: widget.style,
        photos: [
          photos.isNotEmpty ? photos[0] : null,
          photos.length > 1 ? photos[1] : null,
        ],
        cards: [
          LiftCard(
            center: back,
            angle: -.13,
            bytes: photos.length > 1 ? photos[1] : null,
            landDelay: .1,
            rise: h * .27,
            drift: -48,
            spin: -.3,
            swoop: -26,
            landOffset: PhotoLanding.backOffset,
            landAngle: PhotoLanding.backAngle,
          ),
          LiftCard(
            center: front,
            angle: .12,
            bytes: photos.isNotEmpty ? photos[0] : null,
            landDelay: 0,
            rise: h * .31,
            drift: 40,
            spin: .34,
            swoop: 30,
            landOffset: PhotoLanding.frontOffset,
            landAngle: PhotoLanding.frontAngle,
          ),
        ],
      );
      setState(() => _away = true);
      // …and the sheet starts rising while they are still in the air.
      await Future<void>.delayed(const Duration(milliseconds: 380));
    }
    if (!mounted) return;
    if (!PhotoLanding.flying) {
      PhotoLanding.reset();
      PhotoLanding.prepare([
        widget.photos.isNotEmpty ? widget.photos[0] : null,
        widget.photos.length > 1 ? widget.photos[1] : null,
      ], widget.style);
    }
    await widget.onTap();
    PhotoLanding.reset();
    if (mounted) setState(() => _away = false);
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final photos = widget.photos;
    return Tappable(
      onTap: _open,
      semanticLabel: 'Scan from Photos',
      pressedScale: .97,
      child: Container(
        height: _cardHeight(context),
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: s.line),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.35),
              offset: const Offset(0, 10),
              blurRadius: 24,
              spreadRadius: -18,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -42,
              top: -42,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: s.line),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // On a narrow phone the pair scales down to leave the arrow its
                    // room, rather than overflowing.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedOpacity(
                          // Gone the instant the copies take off; they drift
                          // back in once the sheet has closed.
                          opacity: _away ? 0 : 1,
                          duration: _away
                              ? Duration.zero
                              : const Duration(milliseconds: 450),
                          child: _PhotoPair(
                            style: s,
                            photos: photos,
                            frontKey: _frontKey,
                            backKey: _backKey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ArtIcon(ArtIcons.arrowUpRight, size: 18, color: s.muted),
                  ],
                ),
                const Spacer(),
                Text(
                  'Scan from Photos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sans(
                    14.5,
                    weight: FontWeight.w700,
                  ).copyWith(color: s.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  'Discover art from your gallery',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sans(
                    12,
                    weight: FontWeight.w500,
                    height: 1.35,
                  ).copyWith(color: s.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Two small photo cards, overlapping and tilted opposite ways, each with a
/// pale border — the newest in front. Missing photos show a quiet placeholder.
class _PhotoPair extends StatelessWidget {
  const _PhotoPair({
    required this.style,
    required this.photos,
    required this.frontKey,
    required this.backKey,
  });

  final HomeStyle style;
  final List<Uint8List> photos;
  final Key frontKey;
  final Key backKey;

  @override
  Widget build(BuildContext context) {
    final front = photos.isNotEmpty ? photos[0] : null;
    final back = photos.length > 1 ? photos[1] : null;
    return SizedBox(
      width: 82,
      height: 66,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: Transform.rotate(
              angle: -.13,
              child: PhotoCardFace(key: backKey, style: style, bytes: back),
            ),
          ),
          Positioned(
            left: 32,
            top: 2,
            child: Transform.rotate(
              angle: .12,
              child: PhotoCardFace(key: frontKey, style: style, bytes: front),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatefulWidget {
  const _CollectionCard({
    required this.style,
    required this.onTap,
    required this.thumbs,
    required this.label,
  });

  final HomeStyle style;
  final VoidCallback onTap;
  final List<ArtImageSource> thumbs;
  final String label;

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  final _keys = List<GlobalKey>.generate(3, (_) => GlobalKey());

  /// The covers have been released and are in the air.
  bool _away = false;
  bool _busy = false;

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    // The frames swing, so measure from the centre.
    return Rect.fromCenter(
      center: box.localToGlobal(box.size.center(Offset.zero)),
      width: box.size.width,
      height: box.size.height,
    );
  }

  Future<void> _open() async {
    if (_busy) return;
    _busy = true;
    final thumbs = widget.thumbs.take(3).toList();
    final rects = [for (var i = 0; i < thumbs.length; i++) _rectOf(_keys[i])];
    if (thumbs.isNotEmpty &&
        !rects.contains(null) &&
        !AppMotion.reduced(context)) {
      final h = MediaQuery.sizeOf(context).height;
      // Fanned out as they leave: each drifts its own way, and the newest
      // (first) comes down onto the first card of the Collection page.
      const drifts = [36.0, -2.0, -38.0];
      const spins = [.30, .06, -.28];
      const swoops = [28.0, 0.0, -28.0];
      CoverFlight.play(
        context,
        style: widget.style,
        covers: [
          for (var i = 0; i < thumbs.length; i++)
            CoverCard(
              source: thumbs[i],
              start: rects[i]!,
              angle: 0,
              slot: i,
              landDelay: i * .07,
              rise: h * (.3 - i * .02),
              drift: drifts[i],
              spin: spins[i],
              swoop: swoops[i],
            ),
        ],
      );
      setState(() => _away = true);
      // The Collection page arrives while they are still in the air.
      await Future<void>.delayed(const Duration(milliseconds: 380));
    }
    if (!mounted) {
      _busy = false;
      return;
    }
    widget.onTap();
    // Home is hidden behind the page now; bring the covers back unseen, ready
    // for the next visit.
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (mounted) setState(() => _away = false);
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final label = widget.label;
    return Tappable(
      onTap: _open,
      semanticLabel: 'My Collection',
      pressedScale: .97,
      child: Container(
        height: _cardHeight(context),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.6),
              offset: const Offset(0, 14),
              blurRadius: 26,
              spreadRadius: -16,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // One hanging frame for each of the newest saved works (up to
            // three), from nails just inside the card's top edge. With nothing
            // saved yet there are no frames — only the collection icon.
            if (widget.thumbs.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                top: -15,
                child: AnimatedOpacity(
                  // Gone the instant the covers take off; back before the next
                  // visit.
                  opacity: _away ? 0 : 1,
                  duration: _away
                      ? Duration.zero
                      : const Duration(milliseconds: 450),
                  child: HangingFrames(
                    sources: widget.thumbs.take(3).toList(),
                    pictureKeys: _keys,
                  ),
                ),
              )
            else
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0x29D9B46E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ArtIcon(ArtIcons.gallery, size: 20, color: s.goldDeep),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Collection',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      14.5,
                      weight: FontWeight.w700,
                    ).copyWith(color: s.ink),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: s.ink.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: s.ink.withValues(alpha: .14),
                            ),
                          ),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              11,
                              weight: FontWeight.w600,
                            ).copyWith(color: s.ink.withValues(alpha: .85)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Beside the pill, clear of the frames across the top.
                      ArtIcon(
                        ArtIcons.arrowUpRight,
                        size: 18,
                        color: s.goldDeep,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The cards' height: 158 at the normal text size, growing with the system
/// text scale so larger type never crowds the pictures above it.
double _cardHeight(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  return 164 + 48 * (scale - 1).clamp(0.0, .6);
}
