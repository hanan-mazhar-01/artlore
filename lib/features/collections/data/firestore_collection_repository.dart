import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../domain/collection_models.dart';

/// Cloud Firestore implementation of [CollectionRepository] with offline fallback.
class FirestoreCollectionRepository implements CollectionRepository {
  FirestoreCollectionRepository({
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

  final _fallbackGalleries = <Gallery>[
    const Gallery(id: 'favorites', name: 'Favorites'),
  ];

  final _fallbackSaved = <SavedWork>[];

  @override
  Future<CollectionSnapshot> load() async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) {
      return CollectionSnapshot(
        galleries: List.unmodifiable(_fallbackGalleries),
        saved: List.unmodifiable(_fallbackSaved),
      );
    }

    try {
      final userDoc = firestore.collection('users').doc(user.uid);
      final galleriesSnap = await userDoc.collection('galleries').get();
      final savedSnap = await userDoc.collection('saved_works').get();

      final userGalleries = galleriesSnap.docs
          .map((doc) => Gallery(
                id: doc.id,
                name: doc.data()['name'] as String? ?? 'Gallery',
              ))
          .where((g) => g.id != 'favorites')
          .toList();

      final allGalleries = [
        const Gallery(id: 'favorites', name: 'Favorites'),
        ...userGalleries,
      ];

      final saved = savedSnap.docs
          .map((doc) => SavedWork(
                artworkId: doc.data()['artworkId'] as String? ?? doc.id,
                galleryId: doc.data()['galleryId'] as String? ?? 'favorites',
              ))
          .toList();

      return CollectionSnapshot(
        galleries: allGalleries,
        saved: saved,
      );
    } catch (e) {
      debugPrint('FirestoreCollectionRepository load error: $e');
      return CollectionSnapshot(
        galleries: List.unmodifiable(_fallbackGalleries),
        saved: List.unmodifiable(_fallbackSaved),
      );
    }
  }

  @override
  Future<void> save(String artworkId, String galleryId) async {
    _fallbackSaved
      ..removeWhere((s) => s.artworkId == artworkId)
      ..insert(0, SavedWork(artworkId: artworkId, galleryId: galleryId));

    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_works')
          .doc(artworkId)
          .set({
        'artworkId': artworkId,
        'galleryId': galleryId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreCollectionRepository save error: $e');
    }
  }

  @override
  Future<void> remove(String artworkId) async {
    _fallbackSaved.removeWhere((s) => s.artworkId == artworkId);

    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_works')
          .doc(artworkId)
          .delete();
    } catch (e) {
      debugPrint('FirestoreCollectionRepository remove error: $e');
    }
  }

  @override
  Future<void> createGallery(Gallery gallery) async {
    _fallbackGalleries.add(gallery);

    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('galleries')
          .doc(gallery.id)
          .set({'name': gallery.name});
    } catch (e) {
      debugPrint('FirestoreCollectionRepository createGallery error: $e');
    }
  }

  @override
  Future<void> deleteGallery(String galleryId) async {
    _fallbackGalleries.removeWhere((g) => g.id == galleryId);
    _fallbackSaved.removeWhere((s) => s.galleryId == galleryId);

    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;

    try {
      final userDoc = firestore.collection('users').doc(user.uid);
      await userDoc.collection('galleries').doc(galleryId).delete();
      final savedInGallery = await userDoc
          .collection('saved_works')
          .where('galleryId', isEqualTo: galleryId)
          .get();
      for (final doc in savedInGallery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('FirestoreCollectionRepository deleteGallery error: $e');
    }
  }
}
