// lib/features/diary_entry/data/repositories/diary_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_local_data_source.dart';
import '../models/diary_entry_model.dart';

/// Implements [DiaryRepository] by delegating to [DiaryLocalDataSource]
/// and converting thrown exceptions into [Failure]s.
class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource localDataSource;

  const DiaryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, DiaryEntry>> createEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      final created = await localDataSource.createEntry(model);
      return right(created);
    } on AppDatabaseException catch (e) {
      return left(DatabaseFailure(message: e.message));
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getAllEntries() async {
    try {
      final entries = await localDataSource.getAllEntries();
      return right(entries);
    } on AppDatabaseException catch (e) {
      return left(DatabaseFailure(message: e.message));
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> getEntryById(String id) async {
    try {
      final entry = await localDataSource.getEntryById(id);
      return right(entry);
    } on AppDatabaseException catch (e) {
      return left(DatabaseFailure(message: e.message));
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> updateEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      final updated = await localDataSource.updateEntry(model);
      return right(updated);
    } on AppDatabaseException catch (e) {
      return left(DatabaseFailure(message: e.message));
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
      return right(unit);
    } on AppDatabaseException catch (e) {
      return left(DatabaseFailure(message: e.message));
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }
}