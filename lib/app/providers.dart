import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/artwork/data/mock_artwork_repository.dart';
import '../features/artwork/data/mock_detective_repository.dart';
import '../features/artwork/domain/artwork_repository.dart';
import '../features/artwork/domain/detective_case.dart';
import '../features/collections/data/mock_collection_repository.dart';
import '../features/collections/domain/collection_models.dart';
import '../features/history/data/mock_history_repository.dart';
import '../features/home/data/mock_home_repository.dart';
import '../features/home/domain/home_feed.dart';
import '../features/history/domain/history_entry.dart';
import '../features/journey/data/mock_journey_repository.dart';
import '../features/journey/domain/art_journey.dart';
import '../features/paywall/data/mock_purchase_repository.dart';
import '../features/paywall/domain/premium_models.dart';
import '../features/profile/data/mock_profile_repository.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/scan/data/mock_photo_library.dart';
import '../features/scan/data/mock_recognition_repository.dart';
import '../features/scan/domain/photo_library.dart';
import '../features/scan/domain/recognition.dart';
import '../features/settings/data/prefs_settings_repository.dart';
import '../features/settings/domain/app_settings.dart';

/// Composition root: the single place that decides which implementation
/// backs each repository. Swap a mock for Firebase / Gemini / RevenueCat
/// here and no screen changes.

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() with an instance.'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => PrefsSettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final artworkRepositoryProvider = Provider<ArtworkRepository>(
  (ref) => const MockArtworkRepository(),
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => const MockHomeRepository(),
);

final journeyRepositoryProvider = Provider<JourneyRepository>(
  (ref) => const MockJourneyRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => const MockProfileRepository(),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => MockHistoryRepository(),
);

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => MockCollectionRepository(),
);

final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => MockPurchaseRepository(),
);

final recognitionRepositoryProvider = Provider<RecognitionRepository>(
  (ref) => const MockRecognitionRepository(),
);

final photoLibraryProvider = Provider<PhotoLibrary>(
  (ref) => const MockPhotoLibrary(),
);

final detectiveRepositoryProvider = Provider<DetectiveRepository>(
  (ref) => const MockDetectiveRepository(),
);
