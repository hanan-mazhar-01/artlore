import 'package:artlore/features/artwork/data/mock_catalog.dart';
import 'package:artlore/features/collections/presentation/collection_controller.dart';
import 'package:artlore/features/collections/presentation/collection_views.dart';
import 'package:artlore/features/paywall/presentation/premium_controller.dart';
import 'package:artlore/features/settings/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Collection', () {
    test('save puts the work first and marks it saved', () async {
      final c = await makeContainer();
      addTearDown(c.dispose);
      await c.read(collectionProvider.future);
      expect(c.read(isSavedProvider(ArtworkIds.starryNight)), isFalse);

      await c
          .read(collectionProvider.notifier)
          .save(ArtworkIds.starryNight, 'night-skies');

      final snap = c.read(collectionProvider).value!;
      expect(snap.saved.first.artworkId, ArtworkIds.starryNight);
      expect(snap.galleryOf(ArtworkIds.starryNight), 'night-skies');
      expect(c.read(isSavedProvider(ArtworkIds.starryNight)), isTrue);
    });

    test('remove takes the work down', () async {
      final c = await makeContainer();
      addTearDown(c.dispose);
      await c.read(collectionProvider.future);
      await c.read(collectionProvider.notifier).remove(ArtworkIds.kiss);
      expect(
        c.read(collectionProvider).value!.isSaved(ArtworkIds.kiss),
        isFalse,
      );
    });

    test('groups saved works by artist with counts', () {
      final works = [
        mockCatalog[ArtworkIds.pearlEarring]!,
        mockCatalog[ArtworkIds.milkmaid]!,
        mockCatalog[ArtworkIds.kiss]!,
      ];
      final groups = groupArtworks(works, CollectionGrouping.artists);
      expect(groups.first.name, 'Johannes Vermeer');
      expect(groups.first.count, 2);
      expect(groups.first.subtitle, 'Dutch Golden Age · 1632–1675');
    });
  });

  group('Settings', () {
    test('theme mode persists across launches', () async {
      final first = await makeContainer();
      first.read(settingsProvider.notifier).setThemeMode(ThemeMode.light);
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      final prefs = <String, Object>{'artlore.settings.theme': 'light'};
      final second = await makeContainer(prefs);
      addTearDown(second.dispose);
      expect(second.read(themeModeProvider), ThemeMode.light);
    });

    test('defaults to the midnight gallery', () async {
      final c = await makeContainer();
      addTearDown(c.dispose);
      expect(c.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('Premium', () {
    test('free scans are consumed, purchase unlocks', () async {
      final c = await makeContainer();
      addTearDown(c.dispose);
      final before = await c.read(premiumProvider.future);
      await c.read(premiumProvider.notifier).consumeScan();
      expect(
        c.read(premiumProvider).value!.freeScansLeft,
        before.freeScansLeft - 1,
      );
      final ok = await c.read(premiumProvider.notifier).purchase('monthly');
      expect(ok, isTrue);
      expect(c.read(premiumProvider).value!.canScan, isTrue);
    });
  });
}
