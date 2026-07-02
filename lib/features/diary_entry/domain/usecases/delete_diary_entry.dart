// lib/features/diary_entry/domain/usecases/delete_diary_entry.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/diary_repository.dart';

/// Deletes a diary entry by id.
///
/// Milestone 1: hard delete. Milestone 15 (optional) may introduce a
/// Trash/soft-delete flow via `is_deleted` — not in scope here.
class DeleteDiaryEntry {
  final DiaryRepository repository;

  const DeleteDiaryEntry(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteEntry(id);
  }
}