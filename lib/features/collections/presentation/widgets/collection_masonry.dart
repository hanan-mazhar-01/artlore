import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../artwork/domain/artwork.dart';
import '../../../artwork/presentation/widgets/artwork_card.dart';
import 'collection_landing.dart';

/// Uniform card image height so all artworks share equal proportions.
const double collectionCardHeight = 210.0;

/// Preserved for backward-compatibility.
const favoritesRhythm = <double>[collectionCardHeight];
const recentRhythm = <double>[collectionCardHeight];

/// A private gallery wall: two columns with uniform card sizes, staggered
/// vertically ("op nichy"), with a signature column-by-column waterfall
/// reveal where the left column surges up from below first, followed by the
/// right column, settling smoothly into place.
class CollectionMasonry extends StatefulWidget {
  const CollectionMasonry({
    super.key,
    required this.artworks,
    this.cardHeight = collectionCardHeight,
    this.rhythm,
    this.onLongPress,
    this.startDelay = Duration.zero,
  });

  final List<Artwork> artworks;
  final double cardHeight;
  final List<double>? rhythm;
  final ValueChanged<Artwork>? onLongPress;
  final Duration startDelay;

  @override
  State<CollectionMasonry> createState() => _CollectionMasonryState();
}

class _CollectionMasonryState extends State<CollectionMasonry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );
  Timer? _delayTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed) return;
    if (AppMotion.reduced(context)) {
      _c.value = 1.0;
    } else if (widget.startDelay == Duration.zero) {
      _c.forward();
    } else {
      _delayTimer ??= Timer(widget.startDelay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget column(int parity, EdgeInsets padding) {
      final count = (widget.artworks.length - parity + 1) ~/ 2;
      return SliverCrossAxisExpanded(
        flex: 1,
        sliver: SliverPadding(
          padding: padding,
          sliver: SliverList.separated(
            itemCount: count,
            separatorBuilder: (_, _) => const SizedBox(height: 18),
            itemBuilder: (context, row) {
              final i = row * 2 + parity;
              final a = widget.artworks[i];

              // Column-by-column cascade:
              // Left column (parity 0) begins immediately.
              // Right column (parity 1) follows with a distinct column offset.
              final colOffset = parity == 0 ? 0.0 : 0.15;
              final rowOffset = (row % 4) * 0.08;
              final start = (colOffset + rowOffset).clamp(0.0, 0.45);
              final end = (start + 0.55).clamp(0.0, 1.0);

              final cardAnim = CurvedAnimation(
                parent: _c,
                curve: Interval(
                  start,
                  end,
                  curve: const Cubic(0.12, 0.98, 0.24, 1.0),
                ),
              );

              final reveal = AnimatedBuilder(
                animation: _c,
                builder: (context, child) => _CollectionCardReveal(
                  progress: _c.isCompleted ? 1.0 : cardAnim.value,
                  child: child!,
                ),
                child: ArtworkCard(
                  artwork: a,
                  imageHeight: widget.cardHeight,
                  radius: AppRadius.round,
                  titleSize: 16,
                  titleGap: 8,
                  onTap: () => context.openArtwork(a.id),
                  onLongPress: widget.onLongPress == null
                      ? null
                      : () => widget.onLongPress!(a),
                ),
              );
              // The first few cards are where covers flying in from Home land.
              return i < CollectionLanding.keys.length
                  ? CollectionLandingSlot(
                      index: i,
                      imageHeight: widget.cardHeight,
                      radius: AppRadius.round,
                      child: reveal,
                    )
                  : reveal;
            },
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      sliver: SliverCrossAxisGroup(
        slivers: [
          column(0, const EdgeInsets.only(right: 6)),
          column(1, const EdgeInsets.only(left: 6, top: 40)),
        ],
      ),
    );
  }
}

/// A sweeping cinematic card reveal inspired by the prototype motion:
/// cards rise upwards from below, fade in smoothly, and expand into full size.
class _CollectionCardReveal extends StatelessWidget {
  const _CollectionCardReveal({required this.progress, required this.child});

  final double progress;
  final Widget child;

  static const double _slideDistance = 140.0;

  @override
  Widget build(BuildContext context) {
    if (progress >= 1.0) return child;
    final t = progress.clamp(0.0, 1.0);
    return Opacity(
      opacity: Curves.easeOutCubic.transform(t),
      child: Transform.translate(
        offset: Offset(0, _slideDistance * (1.0 - t)),
        child: Transform.scale(scale: 0.90 + 0.10 * t, child: child),
      ),
    );
  }
}
