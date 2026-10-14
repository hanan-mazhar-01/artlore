import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../scan/presentation/scan_launcher.dart';
import 'home_providers.dart';
import 'widgets/home_header.dart';
import 'widgets/home_style.dart';
import 'widgets/home_search.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_scans_section.dart';
import 'widgets/scan_artwork_card.dart';

/// Home — a greeting and search up top, the scan hero, two shortcuts, and the
/// visitor's recent scans. The search field and filter button open the
/// dedicated Search screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCount = ref.watch(
      collectionProvider.select((c) => c.value?.saved.length),
    );
    final pool = ref.watch(homeSearchPoolProvider);
    final latestPhoto = ref.watch(latestPhotoProvider).value;
    final hero = mockCatalog[ArtworkIds.starryNight]!;
    void scan() => ScanLauncher.camera(context);

    Widget reveal(int order, Widget child) => SliverToBoxAdapter(
      child: FadeSlideIn(
        delay: Duration(milliseconds: 80 * order),
        child: child,
      ),
    );

    return ArtScaffold(
      background: HomeStyle.of(context).ground,
      body: CustomScrollView(
        slivers: [
          reveal(0, const HomeHeader()),
          SliverToBoxAdapter(
            child: HomeSearchBar(
              onOpen: () => context.push(AppRoutes.search),
              onFilters: () => context.push(AppRoutes.searchFilters),
            ),
          ),
          reveal(
            1,
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: ScanArtworkCard(
                artwork: hero,
                onTap: scan,
              ),
            ),
          ),
          reveal(
            2,
            QuickActionsRow(
              onScanPhotos: () async {
                await ScanLauncher.fromPhotos(context, ref);
                // The library may have changed while the picker was open.
                ref.invalidate(latestPhotoProvider);
              },
              onCollection: () => context.go(AppRoutes.collection),
              savedCount: savedCount,
              // Saved works come newest first; the card shows the latest 3.
              thumbs: [for (final a in pool.saved.take(3)) a.image],
              latestPhoto: latestPhoto,
            ),
          ),
          reveal(3, RecentScansSection(onScan: scan)),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.tabBarClearance),
          ),
        ],
      ),
    );
  }
}
