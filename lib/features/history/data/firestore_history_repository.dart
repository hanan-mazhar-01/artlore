import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../core/media/art_image_source.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../artwork/domain/artwork.dart';
import '../domain/history_entry.dart';

/// Cloud Firestore implementation of [HistoryRepository] with offline fallback.
class FirestoreHistoryRepository implements HistoryRepository {
  FirestoreHistoryRepository({
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

  final List<HistoryEntry> _fallbackEntries = <HistoryEntry>[];

  @override
  Future<List<HistoryEntry>> fetchHistory() async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) {
      return List.unmodifiable(_fallbackEntries);
    }

    try {
      // 1. Sync any dynamic artworks saved in user's cloud history
      try {
        final dynamicSnap = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('dynamic_artworks')
            .get();
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
        debugPrint('FirestoreHistoryRepository: dynamic_artworks sync note: $e');
      }

      // 2. Fetch history entries
      final snap = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('at', descending: true)
          .limit(50)
          .get();

      if (snap.docs.isEmpty) {
        return const [];
      }

      return snap.docs.map((doc) {
        final d = doc.data();
        final timestamp = d['at'];
        DateTime atDate;
        if (timestamp is Timestamp) {
          atDate = timestamp.toDate();
        } else if (timestamp is String) {
          atDate = DateTime.tryParse(timestamp) ?? DateTime.now();
        } else {
          atDate = DateTime.now();
        }

        return HistoryEntry(
          id: doc.id,
          artworkId: d['artworkId'] as String? ?? '',
          at: atDate,
          where: d['where'] as String? ?? 'ArtLore Museum',
          activity: d['activity'] as String? ?? 'Look Closer',
          scanned: d['scanned'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('FirestoreHistoryRepository fetchHistory error: $e');
      return List.unmodifiable(_fallbackEntries);
    }
  }

  @override
  Future<void> add(HistoryEntry entry) async {
    _fallbackEntries.insert(0, entry);

    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(entry.id)
          .set({
        'artworkId': entry.artworkId,
        'at': Timestamp.fromDate(entry.at),
        'where': entry.where,
        'activity': entry.activity,
        'scanned': entry.scanned,
      });

      // Persist the artwork metadata to the cloud if dynamic
      final art = getArtwork(entry.artworkId);
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
      debugPrint('FirestoreHistoryRepository add error: $e');
    }
  }

  @override
  Future<void> clearLocalCache() async {
    _fallbackEntries.clear();
  }
}

