// lib/features/diary_entry/domain/usecases/update_diary_entry.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Updates an existing diary entry.
///
/// Caller is responsible for setting `updatedAt` on the entry before
/// passing it in (kept explicit rather than stamped here, so later
/// milestones — e.g. streak logic relying on updatedAt — have full
/// visibility into when/why it changes).
class UpdateDiaryEntry {
  final DiaryRepository repository;

  const UpdateDiaryEntry(this.repository);

  Future<Either<Failure, DiaryEntry>> call(DiaryEntry entry) {
    return repository.updateEntry(entry);
  }
}