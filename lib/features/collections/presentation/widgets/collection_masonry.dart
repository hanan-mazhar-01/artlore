import 'package:flutter/widgets.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../artwork/domain/artwork.dart';
import '../../../artwork/presentation/widgets/artwork_card.dart';

/// Card heights for Favorites, cycled so neighbours never line up.
const favoritesRhythm = <double>[230, 180, 240, 210, 250, 150, 200, 160];

/// …and for Recently Viewed.
const recentRhythm = <double>[200, 160, 230, 170, 150, 190];

/// A private gallery wall: two staggered columns (the right one dropped
/// 44pt), each built lazily. Every card shares one soft rounded frame;
/// only the heights vary.
class CollectionMasonry extends StatelessWidget {
  const CollectionMasonry({
    super.key,
    required this.artworks,
    required this.rhythm,
    this.onLongPress,
  });

  final List<Artwork> artworks;
  final List<double> rhythm;
  final ValueChanged<Artwork>? onLongPress;

  @override
  Widget build(BuildContext context) {
    // Item i goes to column i % 2, keeping the design's reading order.
    Widget column(int parity, EdgeInsets padding) {
      final count = (artworks.length - parity + 1) ~/ 2;
      return SliverCrossAxisExpanded(
        flex: 1,
        sliver: SliverPadding(
          padding: padding,
          sliver: SliverList.separated(
            itemCount: count,
            separatorBuilder: (_, _) => const SizedBox(height: 18),
            itemBuilder: (context, row) {
              final i = row * 2 + parity;
              final a = artworks[i];
              final height = rhythm[i % rhythm.length];
              return FadeSlideIn(
                delay: Duration(milliseconds: 40 * (i % 6)),
                child: ArtworkCard(
                  artwork: a,
                  imageHeight: height,
                  radius: AppRadius.round,
                  titleSize: 16,
                  titleGap: 8,
                  onTap: () => context.openArtwork(a.id),
                  onLongPress: onLongPress == null
                      ? null
                      : () => onLongPress!(a),
                ),
              );
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
          column(1, const EdgeInsets.only(left: 6, top: 44)),
        ],
      ),
    );
  }
}
