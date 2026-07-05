// lib/features/diary_entry/domain/repositories/sticker_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

/// Abstracts access to the app's shared sticker library and the local
/// download cache for individual stickers.
///
/// Implemented by [StickerRepositoryImpl], which wraps a Supabase-backed
/// data source and converts thrown exceptions into [Failure] — no
/// caller above this layer needs a try/catch for sticker operations.
abstract class StickerRepository {
  /// Returns every available sticker URL grouped by category (Supabase
  /// storage subfolder name), so the picker UI can render a tab per
  /// category.
  Future<Either<Failure, Map<String, List<String>>>> getStickersByCategory();

  /// Downloads [url] to the local on-device cache and returns the local
  /// file path. If a cached copy already exists on disk, returns that
  /// path immediately without a network request.
  Future<Either<Failure, String>> downloadSticker(String url);
}