// lib/features/diary_entry/domain/repositories/diary_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';

/// Abstract contract for diary entry persistence.
/// Implemented in the data layer; domain and presentation only depend on this.
abstract class DiaryRepository {
  Future<Either<Failure, DiaryEntry>> createEntry(DiaryEntry entry);

  Future<Either<Failure, List<DiaryEntry>>> getAllEntries();

  Future<Either<Failure, DiaryEntry>> getEntryById(String id);

  Future<Either<Failure, DiaryEntry>> updateEntry(DiaryEntry entry);

  Future<Either<Failure, Unit>> deleteEntry(String id);
}