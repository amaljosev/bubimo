// lib/features/diary_entry/data/repositories/sticker_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/sticker_repository.dart';
import '../datasources/supabase_sticker_data_source.dart';

/// Implements [StickerRepository] by delegating to
/// [SupabaseStickerDataSource] and converting any thrown exception into
/// a [Failure], so nothing above this layer ever needs a try/catch for
/// sticker operations — matches [DiaryRepositoryImpl]'s convention.
///
/// Both operations are network-bound (Supabase Storage list calls, or
/// an http download), so failures are surfaced as [NetworkFailure]
/// rather than [DatabaseFailure].
class StickerRepositoryImpl implements StickerRepository {
  final SupabaseStickerDataSource dataSource;

  const StickerRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Map<String, List<String>>>>
      getStickersByCategory() async {
    try {
      final result = await dataSource.getStickersByCategory();
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure('Failed to load stickers: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadSticker(String url) async {
    try {
      final localPath = await dataSource.downloadSticker(url);
      return Right(localPath);
    } catch (e) {
      return Left(NetworkFailure('Failed to download sticker: $e'));
    }
  }
}