import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service to fetch and manage dynamic configuration: the Gemini API key and
/// the share-link base URL. Nothing secret lives in the app's source.
class RemoteConfigService {
  RemoteConfigService([FirebaseRemoteConfig? remoteConfig])
      : _customRemoteConfig = remoteConfig;

  final FirebaseRemoteConfig? _customRemoteConfig;

  static const String geminiKeyParam = 'gemini_api_key';
  static const String shareArtworkBaseUrlParam = 'share_artwork_base_url';
  static const String privacyPolicyUrlParam = 'privacy_policy_url';
  static const String termsOfServiceUrlParam = 'terms_of_service_url';

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseRemoteConfig? get _config {
    if (_customRemoteConfig != null) return _customRemoteConfig;
    if (_isFirebaseReady) return FirebaseRemoteConfig.instance;
    return null;
  }

  Future<void> init() async {
    final config = _config;
    if (config == null) return;
    try {
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );
      await config.setDefaults(const {
        geminiKeyParam: '',
        shareArtworkBaseUrlParam: 'https://artlore.app/artwork',
        privacyPolicyUrlParam: 'https://artlore.app/privacy',
        termsOfServiceUrlParam: 'https://artlore.app/terms',
      });
      final activated = await config.fetchAndActivate();
      debugPrint('RemoteConfigService: fetchAndActivate activated=$activated');
    } catch (e) {
      debugPrint('RemoteConfigService: initialization failed: $e');
    }
  }

  String get geminiApiKey => getString(geminiKeyParam).trim();

  String get shareArtworkBaseUrl {
    final v = getString(shareArtworkBaseUrlParam).trim();
    return v.isEmpty ? 'https://artlore.app/artwork' : v;
  }

  String get privacyPolicyUrl {
    final v = getString(privacyPolicyUrlParam).trim();
    return v.isEmpty ? 'https://artlore.app/privacy' : v;
  }

  String get termsOfServiceUrl {
    final v = getString(termsOfServiceUrlParam).trim();
    return v.isEmpty ? 'https://artlore.app/terms' : v;
  }

  String getString(String key) {
    final config = _config;
    if (config == null) return '';
    return config.getString(key);
  }

  bool getBool(String key) {
    final config = _config;
    if (config == null) return false;
    return config.getBool(key);
  }
}
