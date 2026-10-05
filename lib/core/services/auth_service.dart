import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      if (current != null && current.isAnonymous) {
        try {
          return await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            return await auth.signInWithCredential(credential);
          }
          rethrow;
        }
      }
      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('AuthService: Google sign-in failed: $e');
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
      return await auth.signInAnonymously();
    } catch (e) {
      debugPrint('AuthService: Anonymous sign-in failed: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
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
    if (current != null && current.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      try {
        return await current.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' ||
            e.code == 'credential-already-in-use') {
          return await auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        }
        rethrow;
      }
    }
    return await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
  }
}
