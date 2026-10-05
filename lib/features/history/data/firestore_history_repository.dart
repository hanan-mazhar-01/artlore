import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
    } catch (e) {
      debugPrint('FirestoreHistoryRepository add error: $e');
    }
  }

  @override
  Future<void> clearLocalCache() async {
    _fallbackEntries.clear();
  }
}

