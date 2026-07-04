// lib/features/diary_entry/domain/usecases/get_diary_entry_by_id.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Fetches a single diary entry by id.
///
/// Usage: `await getDiaryEntryById(entryId)`.
class GetDiaryEntryById {
  final DiaryRepository repository;

  const GetDiaryEntryById(this.repository);

  Future<Either<Failure, DiaryEntry>> call(String id) {
    return repository.getEntryById(id);
  }
}