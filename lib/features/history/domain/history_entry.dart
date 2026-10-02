import 'package:flutter/foundation.dart';

/// A painting the visitor stood before, and what they did with it.
@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.artworkId,
    required this.at,
    required this.where,
    required this.activity,
    this.scanned = true,
  });

  final String id;
  final String artworkId;
  final DateTime at;

  /// "Scanned at MoMA, New York".
  final String where;

  /// "Listened 4 min · Explored 4 details".
  final String activity;

  /// Identified through the camera (as opposed to discovered in the app).
  final bool scanned;
}

abstract interface class HistoryRepository {
  /// Newest first.
  Future<List<HistoryEntry>> fetchHistory();
  Future<void> add(HistoryEntry entry);
}
