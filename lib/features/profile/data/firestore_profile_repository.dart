import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../domain/user_profile.dart';

/// Cloud Firestore implementation of [ProfileRepository] with offline fallback.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (_isFirebaseReady) return FirebaseFirestore.instance;
    return null;
  }

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (_isFirebaseReady) return FirebaseAuth.instance;
    return null;
  }

  static const _defaultProfile = UserProfile(
    name: 'Art Visitor',
    memberSince: '2026',
    listeningTime: '0 min',
  );

  static String _resolveInitialName(User? user) {
    if (user == null) return 'Art Visitor';
    final display = user.displayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    final email = user.email;
    if (email != null && email.contains('@')) {
      final handle = email.split('@').first;
      if (handle.isNotEmpty) {
        return handle[0].toUpperCase() + handle.substring(1);
      }
    }
    return user.isAnonymous ? 'Guest Collector' : 'Art Visitor';
  }

  static String _formatMemberSince(User? user) {
    final created = user?.metadata.creationTime ?? DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[created.month - 1]} ${created.year}';
  }

  @override
  Future<UserProfile> fetchProfile() async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) {
      return _defaultProfile;
    }

    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserProfile(
          name: data['name'] as String? ??
              _resolveInitialName(user),
          memberSince:
              data['memberSince'] as String? ?? _formatMemberSince(user),
          listeningTime: data['listeningTime'] as String? ??
              _defaultProfile.listeningTime,
        );
      } else {
        final initialName = _resolveInitialName(user);
        final profile = UserProfile(
          name: initialName,
          memberSince: _formatMemberSince(user),
          listeningTime: '0 min',
        );
        await saveProfile(profile);
        return profile;
      }
    } catch (e) {
      debugPrint('FirestoreProfileRepository error: $e');
      return _defaultProfile;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;

    try {
      await firestore.collection('users').doc(user.uid).set({
        'name': profile.name,
        'memberSince': profile.memberSince,
        'listeningTime': profile.listeningTime,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreProfileRepository saveProfile error: $e');
    }
  }

  @override
  Future<void> updateName(String name) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
      } catch (_) {}
    }
    if (firestore != null && user != null) {
      try {
        await firestore.collection('users').doc(user.uid).set({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('FirestoreProfileRepository updateName error: $e');
      }
    }
  }

  @override
  Future<void> deleteAccount() async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore != null && user != null) {
      try {
        final userDoc = firestore.collection('users').doc(user.uid);
        final galleries = await userDoc.collection('galleries').get();
        for (final doc in galleries.docs) {
          await doc.reference.delete();
        }
        final saved = await userDoc.collection('saved_works').get();
        for (final doc in saved.docs) {
          await doc.reference.delete();
        }
        final history = await userDoc.collection('history').get();
        for (final doc in history.docs) {
          await doc.reference.delete();
        }
        await userDoc.delete();
        // `deviceTrials/{deviceId}` is deliberately NOT touched here — it's
        // the one-time per-device free-trial record and must survive
        // account deletion so a new account on this device can't re-claim it.
        await firestore.collection('entitlements').doc(user.uid).delete();
      } catch (e) {
        debugPrint('FirestoreProfileRepository deleteAccount data error: $e');
      }
    }
    if (user != null) {
      try {
        await user.delete();
      } catch (e) {
        debugPrint('FirestoreProfileRepository delete user error: $e');
        rethrow;
      }
    }
  }
}
