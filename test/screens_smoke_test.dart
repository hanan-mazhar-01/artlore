import 'package:artlore/app/router.dart';
import 'package:artlore/core/router/app_routes.dart';
import 'package:artlore/features/artwork/data/mock_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Every route renders without layout overflow or runtime errors, in both
/// themes and on a small and a large iPhone.
void main() {
  const starry = ArtworkIds.starryNight;
  final routes = [
    AppRoutes.home,
    AppRoutes.collection,
    AppRoutes.profile,
    AppRoutes.scan,
    AppRoutes.readingPhoto(ArtworkIds.kiss),
    AppRoutes.artwork(starry),
    AppRoutes.artwork(ArtworkIds.kiss),
    AppRoutes.story(starry),
    AppRoutes.lookCloser(starry),
    AppRoutes.listen(starry),
    AppRoutes.compare(starry),
    AppRoutes.detective,
    AppRoutes.history,
    AppRoutes.personality,
    AppRoutes.paywall,
    AppRoutes.settings,
    AppRoutes.welcome,
    AppRoutes.onboarding,
  ];

  const devices = {
    'iPhone 15': (Size(1170, 2532), 3.0, 141.0, 102.0),
    'iPhone SE': (Size(750, 1334), 2.0, 40.0, 0.0),
  };

  for (final MapEntry(key: device, value: spec) in devices.entries) {
    for (final theme in ['dark', 'light']) {
      testWidgets('all screens · $device · $theme', (t) async {
        t.view.physicalSize = spec.$1;
        t.view.devicePixelRatio = spec.$2;
        t.view.padding = FakeViewPadding(top: spec.$3, bottom: spec.$4);
        addTearDown(t.view.reset);

        final c = await makeContainer({
          'artlore.settings.onboarded': true,
          'artlore.settings.theme': theme,
        });
        addTearDown(c.dispose);
        await t.pumpWidget(appWith(c));
        await t.pump(const Duration(milliseconds: 3600));
        await t.pump(const Duration(seconds: 1));
        expect(t.takeException(), isNull);

        final router = c.read(routerProvider);
        for (final path in routes) {
          router.go(path);
          await t.pump();
          await t.pump(const Duration(milliseconds: 900));
          await t.pump(const Duration(milliseconds: 900));
          expect(t.takeException(), isNull, reason: 'while showing $path');
        }

        // Leave on a calm screen so no scan/analysis timers linger.
        router.go(AppRoutes.home);
        await t.pump(const Duration(seconds: 2));
      });
    }
  }
}
