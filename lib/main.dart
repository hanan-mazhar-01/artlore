import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/services/remote_config_service.dart';
import 'firebase_options.dart';

import 'features/artwork/data/dynamic_artwork_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await RemoteConfigService().init();
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  DynamicArtworkStorage.init(prefs);
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ArtLoreApp(),
    ),
  );
}
