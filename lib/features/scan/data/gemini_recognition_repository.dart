import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

import '../../../core/media/art_image_source.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/remote_config_service.dart';
import '../../artwork/data/dynamic_artwork_storage.dart';
import '../../artwork/data/mock_catalog.dart';
import '../../artwork/domain/artwork.dart';
import '../../artwork/domain/artwork_content.dart';
import '../domain/recognition.dart';

/// Production recognition repository powered by Gemini Vision & Cloudinary.
class GeminiRecognitionRepository implements RecognitionRepository {
  GeminiRecognitionRepository({
    required this.remoteConfig,
    required this.cloudinaryService,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final RemoteConfigService remoteConfig;
  final CloudinaryService cloudinaryService;
  final http.Client _client;

  static const _models = [
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
    'gemini-flash-latest',
  ];

  @override
  Future<Identification> identify(CapturedFrame frame) async {
    final picked = frame.photoId;
    if (picked != null && mockCatalog.containsKey(picked)) {
      return Identification(
        artworkId: picked,
        where: 'Scanned from a photo',
      );
    }

    final bytes = frame.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      final hash = DynamicArtworkStorage.hashOf(bytes);
      final cachedId = DynamicArtworkStorage.artworkIdForHash(hash);
      if (cachedId != null && hasArtwork(cachedId)) {
        return Identification(artworkId: cachedId, where: 'Scanned from a photo');
      }

      final apiKey = remoteConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        debugPrint('Gemini vision identification error: no API key from Remote Config.');
        cloudinaryService.uploadImageBytes(bytes).catchError((_) => null);
        throw const RecognitionFailedException('No Gemini API key configured.');
      }

      final failures = <String>[];
      try {
        final result = await _recognizeWithGemini(bytes, apiKey, hash, failures);
        if (result != null) {
          cloudinaryService.uploadImageBytes(bytes).catchError((_) => null);
          return result;
        }
      } on UnsupportedSubjectException {
        cloudinaryService.uploadImageBytes(bytes).catchError((_) => null);
        rethrow;
      } catch (e) {
        debugPrint('Gemini vision identification error: $e');
        failures.add(e.toString());
      }

      cloudinaryService.uploadImageBytes(bytes).catchError((_) => null);
      throw RecognitionFailedException(
        failures.isEmpty ? 'Artwork could not be recognized.' : failures.join(' | '),
      );
    }

    throw const RecognitionFailedException();
  }

  Future<Identification?> _recognizeWithGemini(
    Uint8List bytes,
    String apiKey,
    String imageHash,
    List<String> failures,
  ) async {
    final base64Image = base64Encode(bytes);
    const prompt = '''
First, decide: is this photo actually of a painting, drawing, print, or similar artwork? If it clearly shows something else instead — a person, an everyday object, a random scene with no artwork in it, a document, etc. — set "isArtwork" to false, briefly say what it actually shows in "notArtworkReason", and leave every other field as an empty string or empty array. ArtLore only identifies paintings and artworks; don't force an artistic reading onto something that plainly isn't one.

Otherwise set "isArtwork" to true and identify the artwork.

Only claim it is a specific, named famous artwork (with a real artist, title, year, and museum) if you clearly and confidently recognize it as that exact, widely known work — the kind any art-literate person would immediately name on sight (e.g. "The Starry Night", "Girl with a Pearl Earring"). Never guess: if it merely resembles a famous style, or you are not fully certain which specific work this is, do NOT invent or attach the name of an unrelated famous painting, artist, or museum just to sound confident — a wrong specific answer is worse than an honest unknown.

If you don't have a confirmed, specific identity, describe it honestly with artistic sensibility instead: artist as 'Contemporary Eye', a movement that genuinely matches what's visible (e.g. 'Minimalism', 'Realism'), and an evocative title you create for it. Never fall back to a different famous painting's name here either.

For the supporting details (year, medium, dimensions, museum/location, movement) — only fill in a specific value if you're actually confident it's correct. Otherwise write exactly "Unknown" for that field rather than guessing a plausible-sounding but unverified value.

Return ONLY valid JSON with no markdown and no backticks.
Format:
{
  "isArtwork": true,
  "notArtworkReason": "<if isArtwork is false, briefly what the photo actually shows; else empty string>",
  "artworkId": "<catalog id if one of catalog ids, else kebab-case title>",
  "title": "<Artwork Title>",
  "artist": "<Artist Full Name>",
  "artistShort": "<Artist Last Name or Short Name>",
  "artistLife": "<Artist Life dates or Era>",
  "year": "<Year or Period, or \\"Unknown\\">",
  "medium": "<e.g. Woodblock print, Oil on canvas, Digital capture, or \\"Unknown\\">",
  "dimensions": "<Dimensions, or \\"Unknown\\">",
  "museum": "<Museum name or Current location, or \\"Unknown\\">",
  "city": "<City, or \\"Unknown\\">",
  "movement": "<Art Movement or Style, or \\"Unknown\\">",
  "summary": "<2-3 sentence engaging insight about this work>",
  "story": [
    {
      "label": "History",
      "heading": "<Heading>",
      "opening": "<Opening paragraph>",
      "quote": "<Quote>",
      "quoteSource": "<Source>",
      "closing": "<Closing>"
    },
    {
      "label": "Technique",
      "heading": "<Heading>",
      "opening": "<Opening paragraph>",
      "quote": "<Quote>",
      "quoteSource": "<Source>",
      "closing": "<Closing>"
    },
    {
      "label": "Interpretation",
      "heading": "<Heading>",
      "opening": "<Opening paragraph>",
      "quote": "<Quote>",
      "quoteSource": "<Source>",
      "closing": "<Closing>"
    }
  ],
  "details": [
    {
      "title": "<Focal Point Title>",
      "x": 0.5,
      "y": 0.4,
      "description": "<Fascinating detail description>"
    }
  ]
}
Catalog IDs: 'starry-night', 'fighting-temeraire', 'great-wave', 'pearl-earring', 'impression-sunrise', 'wanderer', 'the-kiss', 'sunflowers', 'milkmaid', 'grande-jatte'.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'response_mime_type': 'application/json',
      }
    });

    for (final model in _models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final res = await _client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (res.statusCode != 200) {
          final reason = '$model: HTTP ${res.statusCode} ${_shorten(res.body)}';
          debugPrint('Gemini $reason');
          failures.add(reason);
          continue;
        }

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          failures.add('$model: no candidates in response');
          continue;
        }

        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          failures.add('$model: empty content parts');
          continue;
        }

        String? text;
        for (final part in parts) {
          if (part is Map<String, dynamic> &&
              part['text'] is String &&
              part['thought'] != true) {
            text = part['text'] as String;
            break;
          }
        }

        if (text == null || text.trim().isEmpty) {
          failures.add('$model: empty text part');
          continue;
        }

        final id = _parseIdentification(text, bytes, imageHash);
        if (id != null) return id;
        failures.add('$model: response did not parse as JSON');
      } on UnsupportedSubjectException {
        rethrow;
      } catch (e) {
        final reason = '$model: $e';
        debugPrint('Gemini $reason');
        failures.add(reason);
      }
    }

    return null;
  }

  static String _shorten(String s) => s.length > 200 ? '${s.substring(0, 200)}…' : s;

  Identification? _parseIdentification(
    String rawText,
    Uint8List bytes,
    String imageHash,
  ) {
    try {
      var cleaned = rawText.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
        if (cleaned.endsWith('```')) {
          cleaned = cleaned.substring(0, cleaned.length - 3);
        }
      }
      cleaned = cleaned.trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

      if (parsed['isArtwork'] == false) {
        final reason = (parsed['notArtworkReason'] as String?)?.trim();
        throw UnsupportedSubjectException(reason?.isNotEmpty == true ? reason : null);
      }

      final rawId = (parsed['artworkId'] as String? ?? '').toLowerCase().trim();
      final title = parsed['title'] as String? ?? 'Discovered Artwork';
      final artist = parsed['artist'] as String? ?? 'Contemporary Artist';
      final museum = parsed['museum'] as String? ?? 'Unknown';
      final city = parsed['city'] as String? ?? 'Unknown';

      final dynamicId = rawId.isNotEmpty
          ? rawId
          : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');

      debugPrint('ArtLore Gemini recognized: "$title" by "$artist" (id: $dynamicId)');

      final newArtwork = Artwork(
        id: dynamicId,
        title: title,
        artist: artist,
        artistShort: parsed['artistShort'] as String? ?? artist.split(' ').last,
        artistLife: parsed['artistLife'] as String? ?? '',
        year: parsed['year'] as String? ?? 'Unknown',
        medium: parsed['medium'] as String? ?? 'Unknown',
        dimensions: parsed['dimensions'] as String? ?? 'Unknown',
        museum: museum,
        city: city,
        movement: parsed['movement'] as String? ?? 'Unknown',
        summary: parsed['summary'] as String? ??
            'A compelling artwork discovered and analyzed with ArtLore.',
        image: ArtImageSource.memory(bytes),
      );

      registerDynamicArtwork(newArtwork);
      DynamicArtworkStorage.rememberHash(imageHash, dynamicId);

      final rawStory = parsed['story'] as List?;
      final chapters = <StoryChapter>[];
      if (rawStory != null) {
        for (final ch in rawStory) {
          if (ch is Map<String, dynamic>) {
            chapters.add(StoryChapter(
              label: ch['label'] as String? ?? 'Context',
              focus: Alignment.center,
              heading: ch['heading'] as String? ?? title,
              opening: ch['opening'] as String? ?? '',
              quote: ch['quote'] as String? ?? '',
              quoteSource: ch['quoteSource'] as String? ?? artist,
              closing: ch['closing'] as String? ?? '',
            ));
          }
        }
      }

      final rawDetails = parsed['details'] as List?;
      final details = <ArtworkDetail>[];
      if (rawDetails != null) {
        for (final d in rawDetails) {
          if (d is Map<String, dynamic>) {
            final x = (d['x'] as num?)?.toDouble() ?? 0.5;
            final y = (d['y'] as num?)?.toDouble() ?? 0.5;
            details.add(ArtworkDetail(
              title: d['title'] as String? ?? 'Visual Focus',
              x: x.clamp(0.0, 1.0),
              y: y.clamp(0.0, 1.0),
              description: d['description'] as String? ?? '',
            ));
          }
        }
      }

      if (chapters.isNotEmpty || details.isNotEmpty) {
        registerDynamicContent(
          dynamicId,
          ArtworkContent(story: chapters, details: details),
        );
      }

      final String where;
      if (museum != 'Unknown' && city != 'Unknown') {
        where = 'Scanned at $museum, $city';
      } else if (museum != 'Unknown') {
        where = 'Scanned at $museum';
      } else {
        where = 'Scanned from a photo';
      }

      return Identification(artworkId: dynamicId, where: where);
    } on UnsupportedSubjectException {
      rethrow;
    } catch (e) {
      debugPrint('Parsing identification error: $e');
      return null;
    }
  }
}
