import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../artwork/data/dynamic_artwork_storage.dart';
import '../domain/user_profile.dart';

/// Cloud Firestore implementation of [ProfileRepository] with offline fallback.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _customFirestore = firestore,
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

  static Future<String?> _resolvePhoto(User? user) async {
    if (user == null) return null;
    final direct = user.photoURL?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    for (final info in user.providerData) {
      final pPhoto = info.photoURL?.trim();
      if (pPhoto != null && pPhoto.isNotEmpty) return pPhoto;
    }
    try {
      var gUser = GoogleSignIn().currentUser;
      gUser ??= await GoogleSignIn().signInSilently();
      final gPhoto = gUser?.photoUrl?.trim();
      if (gPhoto != null && gPhoto.isNotEmpty) return gPhoto;
    } catch (_) {}
    return null;
  }

  static String _resolveInitialName(User? user) {
    if (user == null) return 'Art Visitor';
    final display = user.displayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    for (final info in user.providerData) {
      final pDisplay = info.displayName?.trim();
      if (pDisplay != null && pDisplay.isNotEmpty) return pDisplay;
    }
    try {
      final gName = GoogleSignIn().currentUser?.displayName?.trim();
      if (gName != null && gName.isNotEmpty) return gName;
    } catch (_) {}
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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

    final userPhoto = await _resolvePhoto(user);
    final initialName = _resolveInitialName(user);

    try {
      final doc = await firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final storedName = (data['name'] as String?)?.trim();
        final storedPhoto = (data['photoUrl'] as String?)?.trim();

        // If stored name is missing, generic placeholder, or raw email handle prefix,
        // and Google provides a real display name, heal with the real name.
        final emailHandle = (user.email != null && user.email!.contains('@'))
            ? user.email!.split('@').first
            : null;
        final isEmailHandle =
            emailHandle != null &&
            (storedName?.toLowerCase() == emailHandle.toLowerCase());

        final isPlaceholder =
            storedName == null ||
            storedName.isEmpty ||
            storedName == 'Art Visitor' ||
            storedName == 'Guest Collector' ||
            isEmailHandle;

        final resolvedName =
            (isPlaceholder &&
                initialName != 'Art Visitor' &&
                initialName != 'Guest Collector')
            ? initialName
            : (storedName != null && storedName.isNotEmpty
                  ? storedName
                  : initialName);

        final resolvedPhoto = (storedPhoto != null && storedPhoto.isNotEmpty)
            ? storedPhoto
            : userPhoto;

        if (storedName != resolvedName || storedPhoto != resolvedPhoto) {
          await firestore.collection('users').doc(user.uid).set({
            'name': resolvedName,
            if (resolvedPhoto != null && resolvedPhoto.isNotEmpty)
              'photoUrl': resolvedPhoto,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        return UserProfile(
          name: resolvedName,
          memberSince:
              data['memberSince'] as String? ?? _formatMemberSince(user),
          listeningTime:
              data['listeningTime'] as String? ?? _defaultProfile.listeningTime,
          photoUrl: resolvedPhoto,
        );
      } else {
        final profile = UserProfile(
          name: initialName,
          memberSince: _formatMemberSince(user),
          listeningTime: '0 min',
          photoUrl: userPhoto,
        );
        await saveProfile(profile);
        return profile;
      }
    } catch (e) {
      debugPrint('FirestoreProfileRepository error: $e');
      return UserProfile(
        name: _resolveInitialName(user),
        memberSince: _formatMemberSince(user),
        listeningTime: '0 min',
        photoUrl: userPhoto,
      );
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
        if (profile.photoUrl != null) 'photoUrl': profile.photoUrl,
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
      final userDoc = firestore.collection('users').doc(user.uid);

      // 1. Delete galleries subcollection
      try {
        final galleries = await userDoc.collection('galleries').get();
        for (final doc in galleries.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('FirestoreProfileRepository delete galleries error: $e');
      }

      // 2. Delete saved_works subcollection
      try {
        final saved = await userDoc.collection('saved_works').get();
        for (final doc in saved.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('FirestoreProfileRepository delete saved_works error: $e');
      }

      // 3. Delete history subcollection
      try {
        final history = await userDoc.collection('history').get();
        for (final doc in history.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('FirestoreProfileRepository delete history error: $e');
      }

      // 4. Delete dynamic_artworks subcollection
      try {
        final dynamicArtworks = await userDoc
            .collection('dynamic_artworks')
            .get();
        for (final doc in dynamicArtworks.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint(
          'FirestoreProfileRepository delete dynamic_artworks error: $e',
        );
      }

      // 5. Delete root user document
      try {
        await userDoc.delete();
      } catch (e) {
        debugPrint('FirestoreProfileRepository delete userDoc error: $e');
      }

      // 6. Delete entitlements record
      // Note: `deviceTrials/{deviceId}` is deliberately kept to prevent
      // deleting and recreating accounts to claim free scans indefinitely.
      try {
        await firestore.collection('entitlements').doc(user.uid).delete();
      } catch (e) {
        debugPrint('FirestoreProfileRepository delete entitlements error: $e');
      }
    }

    try {
      await DynamicArtworkStorage.clearAll();
    } catch (e) {
      debugPrint(
        'FirestoreProfileRepository deleteAccount storage clear error: $e',
      );
    }

    if (user != null) {
      try {
        await user.delete();
        debugPrint(
          'FirestoreProfileRepository: user deleted successfully from FirebaseAuth',
        );
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          debugPrint(
            'FirestoreProfileRepository: requires-recent-login detected, attempting reauthentication',
          );
          final isGoogle = user.providerData.any(
            (p) => p.providerId == 'google.com',
          );
          final isApple = user.providerData.any(
            (p) => p.providerId == 'apple.com',
          );

          if (isGoogle) {
            try {
              final googleSignIn = GoogleSignIn(
                clientId:
                    (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.macOS)
                    ? '547369793339-699bhnh9luu389f2j6ero3o28ucr205o.apps.googleusercontent.com'
                    : null,
              );
              GoogleSignInAccount? gUser;
              try {
                gUser = await googleSignIn.signInSilently(reAuthenticate: true);
              } catch (_) {}
              gUser ??= await googleSignIn.signIn();
              if (gUser != null) {
                final auth = await gUser.authentication;
                final cred = GoogleAuthProvider.credential(
                  accessToken: auth.accessToken,
                  idToken: auth.idToken,
                );
                await user.reauthenticateWithCredential(cred);
                await user.delete();
                debugPrint(
                  'FirestoreProfileRepository: user successfully reauthenticated with Google and deleted',
                );
                return;
              }
            } catch (reauthErr) {
              debugPrint(
                'FirestoreProfileRepository: Google re-authentication failed: $reauthErr',
              );
            }
          } else if (isApple) {
            try {
              final appleProvider = AppleAuthProvider();
              await user.reauthenticateWithProvider(appleProvider);
              await user.delete();
              debugPrint(
                'FirestoreProfileRepository: user successfully reauthenticated with Apple and deleted',
              );
              return;
            } catch (reauthErr) {
              debugPrint(
                'FirestoreProfileRepository: Apple re-authentication failed: $reauthErr',
              );
            }
          }
          debugPrint(
            'FirestoreProfileRepository: FirebaseAuth user delete skipped; data already purged.',
          );
        } else {
          debugPrint(
            'FirestoreProfileRepository delete user FirebaseAuthException: $e',
          );
        }
      } catch (e) {
        debugPrint(
          'FirestoreProfileRepository delete user unexpected error: $e',
        );
      }
      // Reaching here means the sign-in itself was not deleted: say so, rather
      // than letting the visitor believe the account is gone.
      throw const AccountDeletionException();
    }
  }
}

/// The account's data was cleared but its sign-in could not be deleted (for
/// example, the visitor did not complete re-authentication).
class AccountDeletionException implements Exception {
  const AccountDeletionException();

  @override
  String toString() => 'AccountDeletionException';
}
