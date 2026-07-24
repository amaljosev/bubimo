// lib/features/cloud_backup/domain/repositories/cloud_backup_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cloud_backup_metadata.dart';

/// Coarse phase of an in-progress cloud backup/restore operation, for
/// UI progress feedback.
///
/// Simpler than a per-image progress count (which the equivalent local
/// feature this was adapted from used) — cloud backup uploads/
/// downloads ONE zip file (the same bundle format `BackupLocalDataSource`
/// already builds for local `.bubimo` export), not many individual
/// image files, so there's no meaningful "3 of 40 images" count to
/// report; only which broad step is running.
enum CloudBackupPhase {
  /// Building the archive locally (reading entries + media into a zip)
  /// — the same work local `.bubimo` export does.
  buildingArchive,

  /// Uploading the built archive to Google Drive.
  uploading,

  /// Downloading the archive from Google Drive.
  downloading,

  /// Applying the downloaded archive — the same import work local
  /// `.bubimo` restore does (media resolution + DB writes).
  restoring,
}

typedef CloudBackupProgressCallback = void Function(CloudBackupPhase phase);

/// Contract for Google Drive-backed cloud backup, implemented by
/// `CloudBackupRepositoryImpl` in the data layer.
///
/// Every method returns `Either<Failure, T>`, matching every other
/// repository in this app. Deliberately has no individual use-case
/// classes wrapping each method — [CloudBackupBloc] depends on this
/// repository directly, the same lighter pattern already used by
/// `StickerRepository` (several related operations, no meaningful
/// per-operation business logic beyond the repository call itself).
abstract class CloudBackupRepository {
  /// Interactive Google sign-in (shows the account picker).
  Future<Either<Failure, void>> signIn();

  /// Silent (non-interactive) sign-in attempt — used on app start to
  /// restore a previous session without prompting. Returns whether a
  /// signed-in account was found.
  Future<Either<Failure, bool>> signInSilently();

  Future<Either<Failure, void>> signOut();

  /// Builds a fresh `.bubimo` archive (same format/content as local
  /// export) and uploads it to the user's Drive `appDataFolder`,
  /// deleting whatever backup was there before — there is only ever
  /// one cloud backup at a time.
  Future<Either<Failure, CloudBackupMetadata>> backUpToCloud({
    CloudBackupProgressCallback? onProgress,
  });

  /// Returns metadata for the current cloud backup, or `Right(null)`
  /// if none exists yet.
  Future<Either<Failure, CloudBackupMetadata?>> getCloudBackupStatus();

  /// Downloads the current cloud backup and applies it — same
  /// new-entry-per-record behavior as local `.bubimo` import (see
  /// `BackupLocalDataSource`'s doc comment): nothing already in the
  /// local diary is ever overwritten or removed.
  Future<Either<Failure, int>> restoreFromCloud({
    CloudBackupProgressCallback? onProgress,
  });

  /// Permanently deletes the cloud backup, if one exists.
  Future<Either<Failure, void>> deleteCloudBackup();
}