import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service to fetch and manage dynamic configuration like Gemini API Key & Cloudinary settings.
class RemoteConfigService {
  RemoteConfigService([FirebaseRemoteConfig? remoteConfig])
      : _customRemoteConfig = remoteConfig;

  final FirebaseRemoteConfig? _customRemoteConfig;

  static const String geminiKeyParam = 'gemini_api_key';
  static const String cloudinaryCloudNameParam = 'cloudinary_cloud_name';
  static const String cloudinaryPresetParam = 'cloudinary_upload_preset';

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
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 0)
              : const Duration(hours: 1),
        ),
      );
      await config.setDefaults(const {
        geminiKeyParam: '',
        cloudinaryCloudNameParam: 'vz6euzlq',
        cloudinaryPresetParam: 'artlore_preset',
      });
      await config.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfigService: initialization failed: $e');
    }
  }

  String get geminiApiKey => getString(geminiKeyParam);

  String get cloudinaryCloudName {
    final v = getString(cloudinaryCloudNameParam);
    return v.isEmpty ? 'vz6euzlq' : v;
  }

  String get cloudinaryUploadPreset {
    final v = getString(cloudinaryPresetParam);
    return v.isEmpty ? 'artlore_preset' : v;
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
