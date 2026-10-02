import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../core/router/page_transitions.dart';
import '../core/router/tab_shell.dart';
import '../features/artwork/presentation/compare/compare_screen.dart';
import '../features/artwork/presentation/detective/detective_screen.dart';
import '../features/artwork/presentation/listen/listen_screen.dart';
import '../features/artwork/presentation/look_closer/look_closer_screen.dart';
import '../features/artwork/presentation/result/artwork_result_screen.dart';
import '../features/artwork/presentation/story/story_screen.dart';
import '../features/collections/presentation/collection_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/journey/presentation/personality_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/scan/presentation/analysis/analysis_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The single router. Auth guards and deep links hang off this later.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    routes: [
      _route(AppRoutes.splash, (_) => const SplashScreen(), ArtTransition.fade),
      _route(AppRoutes.onboarding, (_) => const OnboardingScreen()),
      _route(AppRoutes.welcome, (_) => const WelcomeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (c, s) => artPage(s, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.collection,
                pageBuilder: (c, s) => artPage(s, const CollectionScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (c, s) => artPage(s, const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      _route(AppRoutes.scan, (_) => const ScanScreen(), ArtTransition.fade),
      _route(
        AppRoutes.reading,
        (s) => AnalysisScreen(photoId: s.uri.queryParameters['photo']),
        ArtTransition.fade,
      ),
      GoRoute(
        path: '/artwork/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => artPage(
          s,
          ArtworkResultScreen(artworkId: s.pathParameters['id']!),
          transition: ArtTransition.fade,
          duration: const Duration(milliseconds: 800),
        ),
        routes: [
          GoRoute(
            path: 'story',
            pageBuilder: (c, s) =>
                artPage(s, StoryScreen(artworkId: s.pathParameters['id']!)),
          ),
          GoRoute(
            path: 'look-closer',
            pageBuilder: (c, s) => artPage(
              s,
              LookCloserScreen(artworkId: s.pathParameters['id']!),
              transition: ArtTransition.fade,
            ),
          ),
          GoRoute(
            path: 'listen',
            pageBuilder: (c, s) => artPage(
              s,
              ListenScreen(artworkId: s.pathParameters['id']!),
              transition: ArtTransition.fade,
            ),
          ),
          GoRoute(
            path: 'compare',
            pageBuilder: (c, s) => artPage(
              s,
              CompareScreen(artworkId: s.pathParameters['id']!),
              transition: ArtTransition.fade,
            ),
          ),
        ],
      ),
      _route(AppRoutes.detective, (_) => const DetectiveScreen()),
      _route(AppRoutes.history, (_) => const HistoryScreen()),
      _route(AppRoutes.personality, (_) => const PersonalityScreen()),
      _route(
        AppRoutes.paywall,
        (_) => const PaywallScreen(),
        ArtTransition.fade,
      ),
      _route(AppRoutes.settings, (_) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRoute _route(
  String path,
  Widget Function(GoRouterState state) screen, [
  ArtTransition transition = ArtTransition.fadeUp,
]) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) =>
        artPage(state, screen(state), transition: transition),
  );
}
