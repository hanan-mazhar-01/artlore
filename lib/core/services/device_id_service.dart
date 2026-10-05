import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A stable per-device identifier, used only to cap the free-trial scan
/// allowance to one grant per physical device — independent of how many
/// accounts are created, deleted or re-created on it.
///
/// Android: `ANDROID_ID` (survives app reinstalls, resets on factory reset).
/// iOS: `identifierForVendor` (survives reinstalls while another app from
/// the same vendor remains installed).
/// Other platforms: a random id generated once and cached in prefs.
class DeviceIdService {
  DeviceIdService(this._prefs);

  final SharedPreferences _prefs;
  static const _cacheKey = 'artlore.device_id';

  String? _cached;

  Future<String> getDeviceId() async {
    final cached = _cached ?? _prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      _cached = cached;
      return cached;
    }

    final id = await _resolve();
    _cached = id;
    await _prefs.setString(_cacheKey, id);
    return id;
  }

  Future<String> _resolve() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        if (android.id.isNotEmpty) return 'android:${android.id}';
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        final vendorId = ios.identifierForVendor;
        if (vendorId != null && vendorId.isNotEmpty) return 'ios:$vendorId';
      }
    } catch (e) {
      debugPrint('DeviceIdService: native device id unavailable: $e');
    }
    return 'generated:${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
  }
}
