// lib/features/diary_entry/domain/usecases/update_diary_entry.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Persists changes to an existing diary entry.
///
/// This is intentionally the ONLY update use case in the app. Every
/// future feature that changes a field on an entry — mood, favorite
/// toggle, tags, background, stickers, font, rich content — builds an
/// updated entity via `entry.copyWith(...)` and passes it here, rather
/// than each feature adding its own narrow use case (e.g. avoid creating
/// a separate `ToggleFavorite` use case; just call this with
/// `entry.copyWith(isFavorite: !entry.isFavorite)`).
///
/// Usage: `await updateDiaryEntry(existingEntry.copyWith(isFavorite: true))`.
class UpdateDiaryEntry {
  final DiaryRepository repository;

  const UpdateDiaryEntry(this.repository);

  Future<Either<Failure, void>> call(DiaryEntry entry) {
    return repository.updateEntry(entry);
  }
}