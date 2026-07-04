// lib/features/diary_entry/domain/usecases/get_all_diary_entries.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Fetches all diary entries (excluding soft-deleted ones), most recent
/// first. Used directly by Home's list bloc, and reused by Favorites
/// (in-memory filter by `isFavorite`) and Analytics (derived
/// computations) rather than each needing its own fetch method.
///
/// Usage: `await getAllDiaryEntries()`.
class GetAllDiaryEntries {
  final DiaryRepository repository;

  const GetAllDiaryEntries(this.repository);

  Future<Either<Failure, List<DiaryEntry>>> call() {
    return repository.getAllEntries();
  }
}