// lib/features/backup/domain/usecases/export_diary_backup.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/export_result.dart';
import '../repositories/backup_repository.dart';

/// Creates a `.bubimo` backup bundle of every diary entry and saves it
/// to disk.
///
/// Usage: `await exportDiaryBackup()`.
class ExportDiaryBackup {
  final BackupRepository repository;

  const ExportDiaryBackup(this.repository);

  Future<Either<Failure, ExportResult>> call() {
    return repository.exportBackup();
  }
}