import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../app/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/router/tab_shell.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/art_toast.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../collections/presentation/collection_controller.dart';
import '../../wall/wall_controller.dart';
import '../../scan/presentation/scan_launcher.dart';
import 'home_providers.dart';
import 'widgets/home_header.dart';
import 'widgets/home_style.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_scans_section.dart';
import 'widgets/scan_artwork_card.dart';
import 'widgets/your_wall_section.dart';

/// Home — one scrolling page: a greeting, then the scan banner laid across the
/// top edge of a sheet that holds the two shortcuts and the visitor's recent
/// scans. The sheet shares the page's colour — only its rounded edge and a
/// fine line set it apart — and the banner is part of it, so the whole screen
/// scrolls as one. The search button in the header opens the Search screen.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final _bannerKey = GlobalKey();

  /// The banner's height once laid out; the sheet starts this far down it.
  double? _bannerHeight;

  /// How much of the banner stands above the sheet's top edge.
  static const _above = .36;

  bool _wasActive = false;
  bool _wasVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMeasure();
    _askForPhotos();
  }

  /// The first time an account lands on Home, ask for photo access (see
  /// [askPhotoAccessOnce]). Tried again whenever Home comes back into view or
  /// the account arrives late, until it has been asked.
  void _askForPhotos() {
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) askPhotoAccessOnce(ref);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from another app (the gallery, the camera): pick up new photos.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(latestPhotoProvider);
    }
  }

  /// Back on the Home tab: the photos may have changed meanwhile.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = ActiveTabScope.of(context) == 0;
    if (active && !_wasActive) {
      ref.invalidate(latestPhotoProvider);
      _askForPhotos();
    }
    _wasActive = active;
    // Home sits paused under any page opened over it (a painting's page, the
    // scanner). If something is saved or hung up there, Riverpod's paused
    // listeners can miss it, so the card and the wall would stay as they were.
    // Coming back into view, read everything afresh.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_wasVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
    _wasVisible = visible;
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _bannerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      if (_bannerHeight == null ||
          (_bannerHeight! - box.size.height).abs() > .5) {
        setState(() => _bannerHeight = box.size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // An account that signs in after Home is up is asked then.
    ref.listen(authStateProvider, (_, _) => _askForPhotos());
    final savedCount = ref.watch(
      collectionProvider.select((c) => c.value?.saved.length),
    );
    // The three newest saved works, looked up straight from the catalogue so
    // the My Collection card follows a save or a removal at once.
    final newestSaved = ref.watch(
      collectionProvider.select(
        (c) => (c.value?.savedIds ?? const <String>[]).take(3).toList(),
      ),
    );
    final latestPhotos = ref.watch(latestPhotoProvider).value ?? const [];
    // The wall's paintings, newest hung first — looked up straight from the
    // catalogue, so a painting hung a moment ago is on the wall at once.
    final wallIds = ref.watch(wallProvider);
    final wallWorks = [for (final id in wallIds) ?getArtwork(id)];
    final hero = mockCatalog[ArtworkIds.starryNight]!;
    final style = HomeStyle.of(context);
    void scan() => ScanLauncher.camera(context);
    final bannerHeight = _bannerHeight;

    return ArtScaffold(
      background: style.ground,
      body: NotificationListener<SizeChangedLayoutNotification>(
        // The banner settles after its first frame: lay the sheet out again
        // whenever its height changes.
        onNotification: (_) {
          _scheduleMeasure();
          return false;
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: FadeSlideIn(child: HomeHeader())),
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // The sheet, starting part-way down the banner.
                  if (bannerHeight != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: bannerHeight * _above + 14,
                      bottom: 0,
                      child: _SheetSurface(style: style),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 14),
                      SizeChangedLayoutNotifier(
                        child: Padding(
                          key: _bannerKey,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ScanArtworkCard(
                            artwork: hero,
                            // The card shows the painting's own page — story, Look
                            // Closer, deep dive; the pill inside it scans.
                            onTap: () => context.openArtwork(hero.id),
                            onScan: scan,
                          ),
                        ),
                      ),
                      QuickActionsRow(
                        onScanPhotos: () async {
                          // The first time, ask for photo access here — the
                          // visitor has just chosen to scan from photos — so
                          // the card can show their newest pictures.
                          var access = false;
                          try {
                            access =
                                (await PhotoManager.requestPermissionExtend(
                                  requestOption: photoAccessOption,
                                )).hasAccess;
                          } catch (_) {}
                          if (!context.mounted) return;
                          if (!access) {
                            ArtToast.show(
                              context,
                              'Allow photo access to see your recent photos here.',
                              actionLabel: 'Settings',
                              onAction: PhotoManager.openSetting,
                            );
                          }
                          await ScanLauncher.fromPhotos(context, ref);
                          // The library may have changed while the picker was
                          // open.
                          ref.invalidate(latestPhotoProvider);
                        },
                        onCollection: () => context.go(AppRoutes.collection),
                        savedCount: savedCount,
                        // Saved works come newest first; the card shows the
                        // latest 3.
                        thumbs: [
                          for (final id in newestSaved) ?getArtwork(id)?.image,
                        ],
                        latestPhotos: latestPhotos,
                      ),
                      RecentScansSection(onScan: scan),
                      YourWallSection(
                        works: wallWorks,
                        onTakeDown: (a) =>
                            ref.read(wallProvider.notifier).remove(a.id),
                      ),
                      const SizedBox(height: AppSpacing.tabBarClearance),
                    ],
                  ),
                ],
              ),
            ),
            // If the content is short, the sheet still runs to the screen's
            // bottom edge.
            SliverFillRemaining(
              hasScrollBody: false,
              child: ColoredBox(color: style.ground),
            ),
          ],
        ),
      ),
    );
  }
}

/// The sheet's body: the page's own colour, with a rounded top, a fine edge
/// line and a soft lift in light mode. In dark mode it is a hair lighter than
/// the page, with a fine light edge and no shadow, so it reads as a sheet
/// without showing through the glass banner and cards in front of it.
class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.style});

  final HomeStyle style;

  @override
  Widget build(BuildContext context) {
    if (style.dark) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(const Color(0x0DFFFFFF), style.ground),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          border: Border.all(color: const Color(0x1FFFFFFF), width: 1.2),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.ground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        border: Border.all(color: style.ink.withValues(alpha: .16), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: style.shadow(.20),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, -10),
          ),
        ],
      ),
    );
  }
}
