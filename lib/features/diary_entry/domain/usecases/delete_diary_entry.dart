// lib/features/diary_entry/domain/usecases/delete_diary_entry.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/diary_repository.dart';

/// Permanently deletes a diary entry by id.
///
/// Note: if a Trash/soft-delete feature is adopted later, this can be
/// swapped to call `updateEntry(entry.copyWith(isDeleted: true,
/// deletedAt: DateTime.now()))` instead of a hard delete — the entity
/// already supports this without a schema change.
///
/// Usage: `await deleteDiaryEntry(entryId)`.
class DeleteDiaryEntry {
  final DiaryRepository repository;

  const DeleteDiaryEntry(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteEntry(id);
  }
}