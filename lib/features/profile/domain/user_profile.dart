import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.memberSince,
    required this.listeningTime,
    this.photoUrl,
  });

  final String name;

  /// "March 2026".
  final String memberSince;

  /// "3 h 12 min".
  final String listeningTime;

  /// Optional profile picture / avatar URL (e.g. from Google account).
  final String? photoUrl;

  String get firstName {
    final clean = name.trim();
    if (clean.isEmpty) return 'Visitor';
    if (clean == 'Art Visitor' || clean == 'Guest Collector') return 'Visitor';
    final parts = clean.split(RegExp(r'[\s\u00A0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Visitor' : parts.first;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'[\s\u00A0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }


  UserProfile copyWith({
    String? name,
    String? memberSince,
    String? listeningTime,
    String? photoUrl,
  }) =>
      UserProfile(
        name: name ?? this.name,
        memberSince: memberSince ?? this.memberSince,
        listeningTime: listeningTime ?? this.listeningTime,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}

abstract interface class ProfileRepository {
  Future<UserProfile> fetchProfile();
  Future<void> updateName(String name);
  Future<void> deleteAccount();
}
