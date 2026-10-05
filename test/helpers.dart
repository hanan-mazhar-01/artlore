import 'package:artlore/app/app.dart';
import 'package:artlore/app/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artlore/features/collections/data/mock_collection_repository.dart';
import 'package:artlore/features/history/data/mock_history_repository.dart';
import 'package:artlore/features/paywall/data/mock_purchase_repository.dart';
import 'package:artlore/features/profile/data/mock_profile_repository.dart';
import 'package:artlore/features/scan/data/mock_recognition_repository.dart';

/// A container wired like `main()`, backed by in-memory preferences.
Future<ProviderContainer> makeContainer([
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(instance),
      historyRepositoryProvider.overrideWithValue(MockHistoryRepository()),
      collectionRepositoryProvider.overrideWithValue(MockCollectionRepository()),
      profileRepositoryProvider.overrideWithValue(const MockProfileRepository()),
      recognitionRepositoryProvider.overrideWithValue(const MockRecognitionRepository()),
      purchaseRepositoryProvider.overrideWithValue(MockPurchaseRepository()),
    ],
  );
}

/// The full app inside an [UncontrolledProviderScope].
Widget appWith(ProviderContainer container) =>
    UncontrolledProviderScope(container: container, child: const ArtLoreApp());

/// Renders on an iPhone 15–sized surface (390 × 844 @3x).
void usePhone(WidgetTester t) {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  t.view.padding = const FakeViewPadding(top: 141, bottom: 102);
  addTearDown(t.view.reset);
}
