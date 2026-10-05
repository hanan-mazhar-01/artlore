import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/media/art_image_source.dart';
import '../domain/artwork.dart';
import '../domain/artwork_content.dart';
import 'mock_catalog.dart';

/// Persists user-discovered artworks and AI analysis across app launches.
abstract final class DynamicArtworkStorage {
  static const _keysPref = 'artlore.dynamic_artwork_keys';
  static const _hashIndexPref = 'artlore.image_hash_index';
  static SharedPreferences? _prefs;
  static Map<String, String>? _hashIndex;

  static void init(SharedPreferences prefs) {
    _prefs = prefs;
    final keys = prefs.getStringList(_keysPref) ?? const [];
    for (final id in keys) {
      try {
        final jsonStr = prefs.getString('artlore.dynamic_artwork.$id');
        if (jsonStr != null) {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
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
                : const ArtImageSource.asset('assets/artworks/starry_night.jpg', aspect: 1.0),
          );
          registerDynamicArtwork(art, persist: false);
        }

        final contentStr = prefs.getString('artlore.dynamic_content.$id');
        if (contentStr != null) {
          final cMap = jsonDecode(contentStr) as Map<String, dynamic>;
          final rawStory = cMap['story'] as List?;
          final chapters = <StoryChapter>[];
          if (rawStory != null) {
            for (final ch in rawStory) {
              if (ch is Map<String, dynamic>) {
                chapters.add(StoryChapter(
                  label: ch['label'] as String? ?? 'Context',
                  focus: Alignment.center,
                  heading: ch['heading'] as String? ?? '',
                  opening: ch['opening'] as String? ?? '',
                  quote: ch['quote'] as String? ?? '',
                  quoteSource: ch['quoteSource'] as String? ?? '',
                  closing: ch['closing'] as String? ?? '',
                ));
              }
            }
          }
          final rawDetails = cMap['details'] as List?;
          final details = <ArtworkDetail>[];
          if (rawDetails != null) {
            for (final d in rawDetails) {
              if (d is Map<String, dynamic>) {
                details.add(ArtworkDetail(
                  title: d['title'] as String? ?? 'Visual Focus',
                  x: (d['x'] as num?)?.toDouble() ?? 0.5,
                  y: (d['y'] as num?)?.toDouble() ?? 0.5,
                  description: d['description'] as String? ?? '',
                ));
              }
            }
          }
          if (chapters.isNotEmpty || details.isNotEmpty) {
            registerDynamicContent(
              id,
              ArtworkContent(story: chapters, details: details),
              persist: false,
            );
          }
        }
      } catch (e) {
        debugPrint('DynamicArtworkStorage init error for $id: $e');
      }
    }
  }

  static void saveArtwork(Artwork artwork) {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      final keys = (prefs.getStringList(_keysPref) ?? <String>[]).toList();
      if (!keys.contains(artwork.id)) {
        keys.add(artwork.id);
        prefs.setStringList(_keysPref, keys);
      }
      String? b64;
      final bytes = artwork.image.bytes;
      if (bytes != null) b64 = base64Encode(bytes);
      final map = {
        'id': artwork.id,
        'title': artwork.title,
        'artist': artwork.artist,
        'artistShort': artwork.artistShort,
        'artistLife': artwork.artistLife,
        'year': artwork.year,
        'medium': artwork.medium,
        'dimensions': artwork.dimensions,
        'museum': artwork.museum,
        'city': artwork.city,
        'movement': artwork.movement,
        'summary': artwork.summary,
      };
      if (b64 != null) map['imageBase64'] = b64;
      prefs.setString('artlore.dynamic_artwork.${artwork.id}', jsonEncode(map));
    } catch (e) {
      debugPrint('DynamicArtworkStorage saveArtwork error: $e');
    }
  }

  static void saveContent(String id, ArtworkContent content) {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      final map = {
        'story': [
          for (final c in content.story)
            {
              'label': c.label,
              'heading': c.heading,
              'opening': c.opening,
              'quote': c.quote,
              'quoteSource': c.quoteSource,
              'closing': c.closing,
            }
        ],
        'details': [
          for (final d in content.details)
            {
              'title': d.title,
              'x': d.x,
              'y': d.y,
              'description': d.description,
            }
        ],
      };
      prefs.setString('artlore.dynamic_content.$id', jsonEncode(map));
    } catch (e) {
      debugPrint('DynamicArtworkStorage saveContent error: $e');
    }
  }

  /// A stable fingerprint for a scanned image's bytes.
  static String hashOf(List<int> bytes) => sha256.convert(bytes).toString();

  /// The artwork previously identified from this exact image, if any —
  /// so re-scanning the same photo always returns the same result instead
  /// of a fresh (and possibly different) AI guess.
  static String? artworkIdForHash(String hash) => _loadHashIndex()[hash];

  /// Remembers which artwork a scanned image resolved to.
  static void rememberHash(String hash, String artworkId) {
    final prefs = _prefs;
    if (prefs == null) return;
    final index = _loadHashIndex();
    index[hash] = artworkId;
    prefs.setString(_hashIndexPref, jsonEncode(index));
  }

  static Map<String, String> _loadHashIndex() {
    final cached = _hashIndex;
    if (cached != null) return cached;
    final prefs = _prefs;
    if (prefs == null) return _hashIndex = {};
    try {
      final raw = prefs.getString(_hashIndexPref);
      if (raw == null) return _hashIndex = {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return _hashIndex = decoded.map((k, v) => MapEntry(k, v as String));
    } catch (e) {
      debugPrint('DynamicArtworkStorage hash index load error: $e');
      return _hashIndex = {};
    }
  }
}
