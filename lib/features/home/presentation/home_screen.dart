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
import 'widgets/art_journey_section.dart';
import 'widgets/continue_exploring_section.dart';
import 'widgets/featured_artwork_section.dart';
import 'widgets/greeting_section.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_scans_section.dart';
import 'widgets/scan_artwork_card.dart';

/// Home — camera first. Scanning leads; everything below is the visitor's
/// own trail through art, closing on one editorial feature.
///
/// Each section watches only its own data, so a new scan or save updates
/// one section rather than the page.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(
      homeFeedProvider.select((f) => f.value?.featured),
    );
    final saved = ref.watch(
      collectionProvider.select((c) => c.value?.saved.length),
    );
    void scan() => ScanLauncher.camera(context);

    Widget reveal(int order, Widget child) => SliverToBoxAdapter(
      child: FadeSlideIn(
        delay: Duration(milliseconds: 80 * order),
        child: child,
      ),
    );

    return ArtScaffold(
      body: CustomScrollView(
        slivers: [
          reveal(0, const HomeHeader()),
          reveal(0, const GreetingSection()),
          reveal(
            1,
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
              child: ScanArtworkCard(
                artwork: mockCatalog[ArtworkIds.starryNight]!.image,
                onTap: scan,
              ),
            ),
          ),
          reveal(
            2,
            QuickActionsRow(
              onScanPhotos: () => ScanLauncher.fromPhotos(context, ref),
              onCollection: () => context.go(AppRoutes.collection),
              collectionHint: saved == null
                  ? null
                  : '$saved ${saved == 1 ? 'work' : 'works'} saved',
            ),
          ),
          reveal(3, RecentScansSection(onScan: scan)),
          const SliverToBoxAdapter(child: ContinueExploringSection()),
          const SliverToBoxAdapter(child: ArtJourneySection()),
          if (featured != null)
            SliverToBoxAdapter(
              child: FeaturedArtworkSection(artwork: featured),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.tabBarClearance),
          ),
        ],
      ),
    );
  }
}
