// lib/features/backup/domain/repositories/backup_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/export_result.dart';
import '../entities/import_result.dart';

/// Contract for creating and applying `.bubimo` backup bundles,
/// implemented by `BackupRepositoryImpl` in the data layer.
///
/// Mirrors [DiaryRepository]'s shape: every method returns
/// `Either<Failure, T>` so the presentation layer never needs a raw
/// try/catch.
abstract class BackupRepository {
  /// Creates a `.bubimo` bundle containing every non-deleted diary
  /// entry plus the app's media directory, and saves it to disk.
  ///
  /// See `BackupLocalDataSource.createBackup` for exactly what's
  /// included and where the file is saved.
  Future<Either<Failure, ExportResult>> exportBackup();

  /// Reads and applies the `.bubimo` bundle at [filePath].
  ///
  /// Every entry in the bundle is imported as a brand-new row with a
  /// freshly generated id — existing data is never overwritten or
  /// merged. See `BackupLocalDataSource.importBackup` for the full
  /// validation and path-rewriting process.
  Future<Either<Failure, ImportResult>> importBackup(String filePath);
}