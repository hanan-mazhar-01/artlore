import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/auth_service.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/device_id_service.dart';
import '../core/services/remote_config_service.dart';
import '../features/artwork/data/mock_artwork_repository.dart';
import '../features/artwork/data/mock_detective_repository.dart';
import '../features/artwork/domain/artwork_repository.dart';
import '../features/artwork/domain/detective_case.dart';
import '../features/collections/data/firestore_collection_repository.dart';
import '../features/collections/domain/collection_models.dart';
import '../features/history/data/firestore_history_repository.dart';
import '../features/history/domain/history_entry.dart';
import '../features/journey/data/mock_journey_repository.dart';
import '../features/journey/domain/art_journey.dart';
import '../features/paywall/data/in_app_purchase_repository.dart';
import '../features/paywall/domain/premium_models.dart';
import '../features/profile/data/firestore_profile_repository.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/scan/data/gemini_recognition_repository.dart';
import '../features/scan/data/mock_photo_library.dart';
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

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (ref) => RemoteConfigService(),
);

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => CloudinaryService(
    remoteConfig: ref.watch(remoteConfigServiceProvider),
  ),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => PrefsSettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final artworkRepositoryProvider = Provider<ArtworkRepository>(
  (ref) => const MockArtworkRepository(),
);

final journeyRepositoryProvider = Provider<JourneyRepository>(
  (ref) => const MockJourneyRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FirestoreProfileRepository(),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => FirestoreHistoryRepository(),
);

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => FirestoreCollectionRepository(),
);

final deviceIdServiceProvider = Provider<DeviceIdService>(
  (ref) => DeviceIdService(ref.watch(sharedPreferencesProvider)),
);

final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => InAppPurchaseRepository(
    deviceIdService: ref.watch(deviceIdServiceProvider),
  ),
);

final recognitionRepositoryProvider = Provider<RecognitionRepository>(
  (ref) => GeminiRecognitionRepository(
    remoteConfig: ref.watch(remoteConfigServiceProvider),
    cloudinaryService: ref.watch(cloudinaryServiceProvider),
  ),
);

final photoLibraryProvider = Provider<PhotoLibrary>(
  (ref) => const MockPhotoLibrary(),
);

final detectiveRepositoryProvider = Provider<DetectiveRepository>(
  (ref) => const MockDetectiveRepository(),
);
