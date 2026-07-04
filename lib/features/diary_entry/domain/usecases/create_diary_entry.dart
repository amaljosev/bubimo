// lib/features/diary_entry/domain/usecases/create_diary_entry.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Creates a new diary entry.
///
/// Usage: `await createDiaryEntry(newEntry)`.
class CreateDiaryEntry {
  final DiaryRepository repository;

  const CreateDiaryEntry(this.repository);

  Future<Either<Failure, void>> call(DiaryEntry entry) {
    return repository.createEntry(entry);
  }
}