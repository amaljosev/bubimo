// lib/core/services/supabase_storage_asset_service.dart

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Generic helper for listing and caching files from a folder inside
/// the app's single Supabase Storage bucket. Shared by the backgrounds
/// feature (`bg_presets` folder) and the rich editor's sticker picker
/// (`stickers` folder) — both need the same "list remote files, download
/// once, cache locally forever" behavior.
class SupabaseStorageAssetService {
  final SupabaseClient supabaseClient;

  const SupabaseStorageAssetService(this.supabaseClient);

  static const String bucketName = 'assets';

  /// Lists public URLs for every file in [folder] within the `assets`
  /// bucket. Throws if offline or the request fails — callers should
  /// catch this and fall back to local-only assets, not treat it as
  /// fatal, since the app is offline-first.
  Future<List<String>> listPublicUrls(String folder) async {
    final files = await supabaseClient.storage.from(bucketName).list(
          path: folder,
        );

    return files
        .where((file) => file.name.isNotEmpty && !file.name.startsWith('.'))
        .map(
          (file) => supabaseClient.storage
              .from(bucketName)
              .getPublicUrl('$folder/${file.name}'),
        )
        .toList();
  }

  /// Downloads the file at [url] and caches it under
  /// `<app documents>/<cacheSubfolder>/`, returning the cached local
  /// path. Skips the download if already cached from a previous fetch.
  Future<String> downloadAndCache(String url, String cacheSubfolder) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${documentsDir.path}/$cacheSubfolder');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final fileName = Uri.parse(url).pathSegments.last;
    final localFile = File('${cacheDir.path}/$fileName');

    if (await localFile.exists()) {
      return localFile.path;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download $url: HTTP ${response.statusCode}',
      );
    }

    await localFile.writeAsBytes(response.bodyBytes);
    return localFile.path;
  }
}