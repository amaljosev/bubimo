// lib/features/diary_entry/domain/usecases/get_all_diary_entries.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Fetches all diary entries.
///
/// Milestone 1: no sorting/filtering params — returns whatever order the
/// data source provides. Milestone 2 will extend this (or add a variant)
/// for date-based sort/filter.
class GetAllDiaryEntries {
  final DiaryRepository repository;

  const GetAllDiaryEntries(this.repository);

  Future<Either<Failure, List<DiaryEntry>>> call() {
    return repository.getAllEntries();
  }
}