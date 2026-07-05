// lib/features/diary_entry/data/datasources/supabase_sticker_data_source.dart

import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase Storage + local cache access for stickers. No
/// error-wrapping here — exceptions propagate up to
/// [StickerRepositoryImpl], which is responsible for converting them
/// into `Either<Failure, T>`, matching [DiaryLocalDataSource]'s
/// convention for the split between data source and repository.
///
/// Stickers live in the shared `assets` Supabase Storage bucket under
/// `stickers/<category>/<file>`, one subfolder per category (e.g.
/// `stickers/animals/cat.png`, `stickers/mood/happy.webp`).
class SupabaseStickerDataSource {
  final SupabaseClient _supabase;

  const SupabaseStickerDataSource(this._supabase);

  static const String _bucket = 'assets';
  static const String _rootPath = 'stickers';
  static const int _pageSize = 100;

  static const String _logTag = 'StickerDataSource';

  static const List<String> _supportedFormats = [
    '.webp',
    '.png',
    '.jpg',
    '.jpeg',
  ];

  bool _isSupportedImage(String name) {
    final lower = name.toLowerCase();
    return _supportedFormats.any((ext) => lower.endsWith(ext));
  }

  /// Returns every sticker URL grouped by category (subfolder name).
  ///
  /// Paginates each category with an explicit, incrementing `offset` —
  /// omitting this causes the same page to be fetched forever once a
  /// category has more than [_pageSize] files.
  ///
  /// Category (folder) detection: Supabase Storage represents
  /// subfolders as pseudo-file entries whose `metadata` is either null
  /// or missing an `eTag` — real files always have an `eTag`.
  Future<Map<String, List<String>>> getStickersByCategory() async {
    log('--- getStickersByCategory() START ---', name: _logTag);
    log('bucket="$_bucket" rootPath="$_rootPath"', name: _logTag);

    final List<FileObject> folders;
    try {
      folders = await _supabase.storage.from(_bucket).list(
            path: _rootPath,
          );
    } catch (e, st) {
      log(
        'FAILED to list root path "$_rootPath" in bucket "$_bucket". '
        'This usually means: (a) the bucket name is wrong, (b) RLS/policy '
        'blocks SELECT on storage.objects, or (c) the path does not exist.',
        name: _logTag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    log('Raw entries under "$_rootPath": ${folders.length}', name: _logTag);
    for (final f in folders) {
      log(
        '  entry name="${f.name}" id=${f.id} metadata=${f.metadata}',
        name: _logTag,
      );
    }

    if (folders.isEmpty) {
      log(
        'WARNING: list() returned an EMPTY array for "$_rootPath". '
        'If you expect categories here, the most likely cause is a '
        'missing/incorrect RLS policy on storage.objects for bucket '
        '"$_bucket" — Supabase often returns [] instead of throwing '
        'when access is denied, rather than a 403.',
        name: _logTag,
      );
    }

    final categoryEntries = folders
        .where((f) => f.metadata == null || f.metadata!['eTag'] == null)
        .toList();

    log(
      'Detected ${categoryEntries.length} folder-like entries '
      '(out of ${folders.length} total) using the metadata/eTag heuristic.',
      name: _logTag,
    );

    if (categoryEntries.isEmpty && folders.isNotEmpty) {
      log(
        'WARNING: entries exist under "$_rootPath" but NONE were classified '
        'as folders. This means every entry HAS an eTag/non-null metadata, '
        'so the folder-detection heuristic is filtering everything out. '
        'Check the logged metadata above — if folders show a non-null '
        'metadata map (e.g. "{}" instead of null) in your SDK version, '
        'the heuristic needs adjusting (see notes below the code).',
        name: _logTag,
      );
    }

    final categoryNames = categoryEntries.map((f) => f.name).toList();

    final Map<String, List<String>> result = {};

    for (final category in categoryNames) {
      log('--- Listing category "$category" ---', name: _logTag);
      final urls = <String>[];
      int offset = 0;
      bool hasMore = true;
      int page = 0;

      while (hasMore) {
        final List<FileObject> files;
        try {
          files = await _supabase.storage.from(_bucket).list(
                path: '$_rootPath/$category',
                searchOptions: SearchOptions(
                  limit: _pageSize,
                  offset: offset,
                ),
              );
        } catch (e, st) {
          log(
            'FAILED to list category "$category" at offset $offset',
            name: _logTag,
            error: e,
            stackTrace: st,
          );
          rethrow;
        }

        log(
          'category="$category" page=$page offset=$offset -> '
          '${files.length} entries: ${files.map((f) => f.name).toList()}',
          name: _logTag,
        );

        final imageFiles = files.where((f) => _isSupportedImage(f.name)).toList();

        final skipped = files.where((f) => !_isSupportedImage(f.name)).toList();
        if (skipped.isNotEmpty) {
          log(
            'category="$category" SKIPPED ${skipped.length} entries with '
            'unsupported/no extension: ${skipped.map((f) => f.name).toList()} '
            '(supported: $_supportedFormats)',
            name: _logTag,
          );
        }

        for (final file in imageFiles) {
          final publicUrl = _supabase.storage
              .from(_bucket)
              .getPublicUrl('$_rootPath/$category/${file.name}');
          log('  -> $publicUrl', name: _logTag);
          urls.add(publicUrl);
        }

        if (files.length < _pageSize) {
          hasMore = false;
        } else {
          offset += _pageSize;
          page++;
        }
      }

      log(
        'category="$category" TOTAL usable image URLs: ${urls.length}',
        name: _logTag,
      );
      result[category] = urls;
    }

    log(
      '--- getStickersByCategory() DONE. '
      'Categories: ${result.keys.toList()}. '
      'Counts: ${result.map((k, v) => MapEntry(k, v.length))} ---',
      name: _logTag,
    );

    return result;
  }

  /// Downloads [url] into the local `stickers/` cache directory and
  /// returns the local file path.
  ///
  /// If the file already exists on disk (either from a previous
  /// download, or restored from a backup that preserved app documents),
  /// the cached copy is returned immediately with no network request.
  Future<String> downloadSticker(String url) async {
    log('downloadSticker() START url=$url', name: _logTag);

    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.last;

    final appDir = await getApplicationDocumentsDirectory();
    final stickerDir = Directory('${appDir.path}/stickers');
    if (!await stickerDir.exists()) {
      await stickerDir.create(recursive: true);
      log('Created sticker cache dir at ${stickerDir.path}', name: _logTag);
    }

    final localFile = File('${stickerDir.path}/$fileName');
    if (await localFile.exists()) {
      log('Cache HIT: returning existing file ${localFile.path}', name: _logTag);
      return localFile.path;
    }

    log('Cache MISS. Downloading from network: $uri', name: _logTag);
    final response = await http.get(uri);

    log(
      'HTTP response status=${response.statusCode} '
      'contentType=${response.headers['content-type']} '
      'bodyBytes=${response.bodyBytes.length}',
      name: _logTag,
    );

    if (response.statusCode != 200) {
      log(
        'FAILED to download sticker. status=${response.statusCode}. '
        'If this is 400/403, the bucket is likely NOT public — '
        'getPublicUrl() still returns a URL even for private buckets, '
        'it just won\'t be servable without a signed URL/auth header.',
        name: _logTag,
      );
      throw HttpException(
        'Sticker download failed with status ${response.statusCode}',
      );
    }

    await localFile.writeAsBytes(response.bodyBytes);
    log('Saved sticker to ${localFile.path}', name: _logTag);
    return localFile.path;
  }
}