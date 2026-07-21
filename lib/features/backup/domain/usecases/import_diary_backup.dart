// lib/features/backup/domain/usecases/import_diary_backup.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/import_result.dart';
import '../repositories/backup_repository.dart';

/// Reads and applies a `.bubimo` backup bundle at a given file path.
///
/// Usage: `await importDiaryBackup(pickedFilePath)`.
class ImportDiaryBackup {
  final BackupRepository repository;

  const ImportDiaryBackup(this.repository);

  Future<Either<Failure, ImportResult>> call(String filePath) {
    return repository.importBackup(filePath);
  }
}