import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'remote_config_service.dart';

/// Service for direct unsigned uploads to Cloudinary without requiring a paid server.
class CloudinaryService {
  const CloudinaryService({
    this.remoteConfig,
    this.fallbackCloudName = 'vz6euzlq',
    this.fallbackUploadPreset = 'artlore_preset',
    this.defaultFolder = 'ArtLore',
  });

  final RemoteConfigService? remoteConfig;
  final String fallbackCloudName;
  final String fallbackUploadPreset;
  final String defaultFolder;

  String get cloudName {
    final configured = remoteConfig?.cloudinaryCloudName;
    if (configured != null && configured.isNotEmpty) return configured;
    return fallbackCloudName;
  }

  String get uploadPreset {
    final configured = remoteConfig?.cloudinaryUploadPreset;
    if (configured != null && configured.isNotEmpty) return configured;
    return fallbackUploadPreset;
  }

  Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// Uploads raw image bytes to Cloudinary directly into the [defaultFolder].
  Future<String?> uploadImageBytes(
    Uint8List bytes, {
    String fileName = 'artwork_scan.jpg',
    String? folder,
  }) async {
    try {
      final targetFolder = folder ?? defaultFolder;
      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );

      if (targetFolder.isNotEmpty) {
        request.fields['folder'] = targetFolder;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      } else {
        debugPrint(
          'Cloudinary upload failed with code ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Uploads a file from local device storage using multipart request.
  Future<String?> uploadImagePath(
    String filePath, {
    String? folder,
  }) async {
    try {
      final targetFolder = folder ?? defaultFolder;
      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      if (targetFolder.isNotEmpty) {
        request.fields['folder'] = targetFolder;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      } else {
        debugPrint(
          'Cloudinary upload failed with code ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
