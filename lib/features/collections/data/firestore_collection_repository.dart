import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../core/media/art_image_source.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../artwork/domain/artwork.dart';
import '../domain/collection_models.dart';

/// Cloud Firestore implementation of [CollectionRepository] with offline fallback.
class FirestoreCollectionRepository implements CollectionRepository {
  FirestoreCollectionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _customFirestore = firestore,
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

      // Restore any dynamic artworks saved in the user's cloud account
      try {
        final dynamicSnap = await userDoc.collection('dynamic_artworks').get();
        for (final doc in dynamicSnap.docs) {
          final map = doc.data();
          final id = doc.id;
          if (getArtwork(id) == null) {
            final b64 = map['imageBase64'] as String?;
            final art = Artwork(
              id: id,
              title: map['title'] as String? ?? 'Discovered Artwork',
              artist: map['artist'] as String? ?? 'Artist',
              artistShort: map['artistShort'] as String? ?? '',
              artistLife: map['artistLife'] as String? ?? '',
              year: map['year'] as String? ?? '',
              medium: map['medium'] as String? ?? 'Fine Art',
              dimensions: map['dimensions'] as String? ?? '',
              museum: map['museum'] as String? ?? 'Private Collection',
              city: map['city'] as String? ?? 'Global',
              movement: map['movement'] as String? ?? 'Visual Expression',
              summary: map['summary'] as String? ?? '',
              image: b64 != null
                  ? ArtImageSource.memory(base64Decode(b64))
                  : const ArtImageSource.asset(
                      'assets/artworks/starry_night.jpg',
                      aspect: 1.0,
                    ),
            );
            registerDynamicArtwork(art, persist: true);
          }
        }
      } catch (e) {
        debugPrint(
          'FirestoreCollectionRepository dynamic_artworks sync note: $e',
        );
      }

      final galleriesSnap = await userDoc.collection('galleries').get();
      final savedSnap = await userDoc.collection('saved_works').get();

      final userGalleries = galleriesSnap.docs
          .map(
            (doc) => Gallery(
              id: doc.id,
              name: doc.data()['name'] as String? ?? 'Gallery',
            ),
          )
          .where((g) => g.id != 'favorites')
          .toList();

      final allGalleries = [
        const Gallery(id: 'favorites', name: 'Favorites'),
        ...userGalleries,
      ];

      // Firestore hands documents back in id order, not save order — so sort
      // by when each was saved, newest first, as the rest of the app expects
      // ("the three newest" on Home reads the top of this list). A write that
      // has not reached the server yet has no time: it is the newest of all.
      DateTime savedAt(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final t = doc.data()['savedAt'];
        if (t is Timestamp) return t.toDate();
        return doc.metadata.hasPendingWrites
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(0);
      }

      final ordered = [...savedSnap.docs]
        ..sort((a, b) => savedAt(b).compareTo(savedAt(a)));
      final saved = ordered
          .map(
            (doc) => SavedWork(
              artworkId: doc.data()['artworkId'] as String? ?? doc.id,
              galleryId: doc.data()['galleryId'] as String? ?? 'favorites',
            ),
          )
          .toList();

      return CollectionSnapshot(galleries: allGalleries, saved: saved);
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

      // Persist the artwork metadata to the cloud if dynamic
      final art = getArtwork(artworkId);
      if (art != null) {
        final bytes = art.image.bytes;
        final b64 = bytes != null ? base64Encode(bytes) : null;
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('dynamic_artworks')
            .doc(art.id)
            .set({
              'id': art.id,
              'title': art.title,
              'artist': art.artist,
              'artistShort': art.artistShort,
              'artistLife': art.artistLife,
              'year': art.year,
              'medium': art.medium,
              'dimensions': art.dimensions,
              'museum': art.museum,
              'city': art.city,
              'movement': art.movement,
              'summary': art.summary,
              'imageBase64': ?b64,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
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

  @override
  Future<void> clearLocalCache() async {
    _fallbackGalleries
      ..clear()
      ..add(const Gallery(id: 'favorites', name: 'Favorites'));
    _fallbackSaved.clear();
  }
}
