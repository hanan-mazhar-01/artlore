import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.memberSince,
    required this.listeningTime,
  });

  final String name;

  /// "March 2026".
  final String memberSince;

  /// "3 h 12 min".
  final String listeningTime;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }
}

abstract interface class ProfileRepository {
  Future<UserProfile> fetchProfile();
}
