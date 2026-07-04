// lib/features/diary_entry/data/repositories/diary_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_local_data_source.dart';
import '../models/diary_entry_model.dart';

/// Implements [DiaryRepository] by delegating to [DiaryLocalDataSource]
/// and converting any thrown exception into a [Failure], so nothing
/// above this layer ever needs a try/catch for diary entry operations.
class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource localDataSource;

  const DiaryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> createEntry(DiaryEntry entry) async {
    try {
      await localDataSource.insertEntry(DiaryEntryModel.fromEntity(entry));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create diary entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getAllEntries() async {
    try {
      final entries = await localDataSource.getAllEntries();
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load diary entries: $e'));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> getEntryById(String id) async {
    try {
      final entry = await localDataSource.getEntryById(id);
      return Right(entry);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load diary entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEntry(DiaryEntry entry) async {
    try {
      await localDataSource.updateEntry(DiaryEntryModel.fromEntity(entry));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update diary entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete diary entry: $e'));
    }
  }
}