import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Wraps Firebase Authentication and Google Sign-In with safe fallbacks.
class AuthService {
  AuthService([FirebaseAuth? auth, GoogleSignIn? googleSignIn])
      : _customAuth = auth,
        _customGoogleSignIn = googleSignIn;

  final FirebaseAuth? _customAuth;
  final GoogleSignIn? _customGoogleSignIn;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (_isFirebaseReady) return FirebaseAuth.instance;
    return null;
  }

  GoogleSignIn get _googleSignIn => _customGoogleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Signs in with Google. If the current session is a guest (anonymous)
  /// one, links this credential to it instead of replacing it — preserving
  /// the guest's scan history — unless this Google identity already owns a
  /// separate, real account, in which case that existing account's data
  /// takes over.
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('AuthService: Firebase not initialized.');
      return null;
    }
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final current = auth.currentUser;
      UserCredential credentialResult;
      if (current != null && current.isAnonymous) {
        try {
          credentialResult = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            credentialResult = await auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        credentialResult = await auth.signInWithCredential(credential);
      }

      // Sync name & photo from Google to Firebase Auth user AND Firestore
      final loggedInUser = credentialResult.user ?? auth.currentUser;
      if (loggedInUser != null) {
        _syncRevenueCatUser(loggedInUser.uid);
        final gName = googleUser.displayName;
        final gPhoto = googleUser.photoUrl;
        if (gName != null && gName.isNotEmpty) {
          try {
            await loggedInUser.updateDisplayName(gName);
          } catch (_) {}
        }
        if (gPhoto != null && gPhoto.isNotEmpty) {
          try {
            await loggedInUser.updatePhotoURL(gPhoto);
          } catch (_) {}
        }
        if (Firebase.apps.isNotEmpty) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(loggedInUser.uid)
                .set({
              if (gName != null && gName.isNotEmpty) 'name': gName,
              if (gPhoto != null && gPhoto.isNotEmpty) 'photoUrl': gPhoto,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            debugPrint('AuthService: error saving google profile to firestore: $e');
          }
        }
      }

      return credentialResult;
    } catch (e) {
      debugPrint('AuthService: Google sign-in failed: $e');
      rethrow;
    }
  }

  /// Signs in with Apple. If the current session is a guest (anonymous)
  /// one, links this credential to it instead of replacing it — preserving
  /// the guest's scan history — unless this Apple identity already owns a
  /// separate, real account, in which case that existing account's data
  /// takes over.
  Future<UserCredential?> signInWithApple() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('AuthService: Firebase not initialized.');
      return null;
    }
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final current = auth.currentUser;
      UserCredential credentialResult;
      if (current != null && current.isAnonymous) {
        try {
          credentialResult = await current.linkWithProvider(appleProvider);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            credentialResult = await auth.signInWithProvider(appleProvider);
          } else {
            rethrow;
          }
        }
      } else {
        credentialResult = await auth.signInWithProvider(appleProvider);
      }

      // Sync name to Firebase Auth user AND Firestore
      final loggedInUser = credentialResult.user ?? auth.currentUser;
      if (loggedInUser != null) {
        _syncRevenueCatUser(loggedInUser.uid);
        final appleName = loggedInUser.displayName;
        if (appleName != null && appleName.isNotEmpty) {
          try {
            await loggedInUser.updateDisplayName(appleName);
          } catch (_) {}
        }
        if (Firebase.apps.isNotEmpty) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(loggedInUser.uid)
                .set({
              if (appleName != null && appleName.isNotEmpty) 'name': appleName,
              if (loggedInUser.email != null && loggedInUser.email!.isNotEmpty)
                'email': loggedInUser.email,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            debugPrint('AuthService: error saving apple profile to firestore: $e');
          }
        }
      }

      return credentialResult;
    } catch (e) {
      debugPrint('AuthService: Apple sign-in failed: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('AuthService: Firebase not initialized.');
      return null;
    }
    try {
      final cred = await auth.signInAnonymously();
      if (cred.user != null) {
        _syncRevenueCatUser(cred.user!.uid);
      }
      return cred;
    } catch (e) {
      debugPrint('AuthService: Anonymous sign-in failed: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;
    final cred = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user != null) {
      _syncRevenueCatUser(cred.user!.uid);
    }
    return cred;
  }

  /// Registers with email/password. If the current session is a guest
  /// (anonymous) one, links this credential to it instead of replacing it —
  /// preserving the guest's scan history — unless this email already owns a
  /// separate, real account, in which case that existing account's data
  /// takes over.
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    final auth = _auth;
    if (auth == null) return null;
    final current = auth.currentUser;
    UserCredential cred;
    if (current != null && current.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      try {
        cred = await current.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' ||
            e.code == 'credential-already-in-use') {
          cred = await auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        } else {
          rethrow;
        }
      }
    } else {
      cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
    if (cred.user != null) {
      _syncRevenueCatUser(cred.user!.uid);
    }
    return cred;
  }

  void _syncRevenueCatUser(String? uid) {
    if (kIsWeb) return;
    try {
      if (uid != null && uid.isNotEmpty) {
        Purchases.logIn(uid);
      } else {
        Purchases.logOut();
      }
    } catch (e) {
      debugPrint('AuthService: RevenueCat user sync error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    if (!kIsWeb) {
      try {
        await Purchases.logOut();
      } catch (_) {}
    }
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
  }
}
