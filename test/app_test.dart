import 'package:artlore/app/router.dart';
import 'package:artlore/core/router/app_routes.dart';
import 'package:artlore/core/theme/app_palette.dart';
import 'package:artlore/features/history/presentation/history_controller.dart';
import 'package:artlore/features/paywall/presentation/premium_controller.dart';
import 'package:artlore/features/settings/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// One frame to mount (pushed routes start offstage), then [ms] of time.
Future<void> _settle(WidgetTester t, [int ms = 1200]) async {
  await t.pump();
  await t.pump(Duration(milliseconds: ms));
}

void main() {
  testWidgets('first launch: splash → onboarding → welcome → home', (t) async {
    usePhone(t);
    final c = await makeContainer();
    addTearDown(c.dispose);
    await t.pumpWidget(appWith(c));
    expect(find.text('ArtLore'), findsOneWidget);

    await _settle(t, 3600);
    await _settle(t);
    expect(find.text('Every painting has a story.'), findsOneWidget);

    await t.tap(find.text('Skip'));
    await _settle(t);
    await _settle(t);
    expect(find.text('Continue with Apple'), findsOneWidget);

    await t.tap(find.text('Look around first'));
    await _settle(t);
    await _settle(t);
    expect(find.text('What will you discover today?'), findsOneWidget);
    expect(find.text('Scan Artwork'), findsOneWidget);
    expect(c.read(settingsProvider).onboardingComplete, isTrue);
  });

  testWidgets('returning visitor lands on Home and can open a result', (
    t,
  ) async {
    usePhone(t);
    final c = await makeContainer({'artlore.settings.onboarded': true});
    addTearDown(c.dispose);
    await t.pumpWidget(appWith(c));
    await _settle(t, 3600);
    await _settle(t);
    expect(find.text('Recent scans', skipOffstage: false), findsOneWidget);

    final collection = find.text('My Collection', skipOffstage: false);
    await t.ensureVisible(collection);
    await t.pump();
    await t.tap(collection);
    await _settle(t);
    await _settle(t);
    expect(find.text('Collection'), findsOneWidget);

    c.read(routerProvider).push(AppRoutes.artwork('starry-night'));
    await _settle(t);
    await _settle(t);
    expect(find.text('IDENTIFIED'), findsOneWidget);
    expect(find.text('Look Closer', skipOffstage: false), findsOneWidget);
  });

  testWidgets('theme switches instantly between dark and light', (t) async {
    usePhone(t);
    final c = await makeContainer({'artlore.settings.onboarded': true});
    addTearDown(c.dispose);
    await t.pumpWidget(appWith(c));
    await _settle(t, 3600);
    await _settle(t);

    BuildContext ctx() => t.element(find.text('What will you discover today?'));
    expect(
      Theme.of(ctx()).extension<AppPalette>()!.background,
      AppPalette.dark.background,
    );

    c.read(settingsProvider.notifier).setThemeMode(ThemeMode.light);
    await t.pump();
    await _settle(t, 600);
    expect(
      Theme.of(ctx()).extension<AppPalette>()!.background,
      AppPalette.light.background,
    );
  });

  testWidgets('scan → detect → capture → reading → result', (t) async {
    usePhone(t);
    final semantics = t.ensureSemantics();
    final c = await makeContainer({'artlore.settings.onboarded': true});
    addTearDown(c.dispose);
    await t.pumpWidget(appWith(c));
    await _settle(t, 3600);
    await _settle(t);

    await t.tap(find.bySemanticsLabel('Scan an artwork').first);
    await _settle(t, 800);
    expect(find.text('Align the artwork'), findsOneWidget);
    await _settle(t, 1200);
    expect(find.text('Artwork detected'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Capture artwork'));
    await _settle(t, 700);
    await _settle(t, 700);
    expect(find.text('Reading the artwork…'), findsOneWidget);

    for (var i = 0; i < 8; i++) {
      await _settle(t, 1000);
    }
    expect(find.text('IDENTIFIED'), findsOneWidget);
    expect(c.read(premiumProvider).value!.freeScansLeft, 2);
    expect(c.read(historyProvider).value!.first.artworkId, 'starry-night');
    semantics.dispose();
  });

  testWidgets('scan from photos → pick → reading → that artwork', (t) async {
    usePhone(t);
    final semantics = t.ensureSemantics();
    final c = await makeContainer({'artlore.settings.onboarded': true});
    addTearDown(c.dispose);
    await t.pumpWidget(appWith(c));
    await _settle(t, 3600);
    await _settle(t);

    final photos = find.text('Scan from Photos', skipOffstage: false);
    await t.ensureVisible(photos);
    await t.pump();
    await t.tap(photos);
    await _settle(t, 800);
    expect(find.text('Choose a photograph'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Photo 1'));
    await _settle(t, 900);
    expect(find.text('Reading the artwork…'), findsOneWidget);
    for (var i = 0; i < 8; i++) {
      await _settle(t, 1000);
    }
    expect(find.text('The Kiss'), findsOneWidget);
    expect(c.read(historyProvider).value!.first.where, 'Scanned from a photo');
    semantics.dispose();
  });
}
