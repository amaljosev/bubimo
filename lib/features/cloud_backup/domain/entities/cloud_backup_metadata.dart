// lib/features/cloud_backup/domain/entities/cloud_backup_metadata.dart

import 'package:equatable/equatable.dart';

/// Describes the single `.bubimo` snapshot currently stored in the
/// user's Google Drive `appDataFolder` — pure domain entity, no Drive
/// or googleapis types leak in here.
///
/// There is only ever ONE cloud backup at a time (see
/// `CloudBackupRepositoryImpl`'s doc comment): every new backup deletes
/// whatever was there before, so this describes "the current backup",
/// not one entry in a history.
class CloudBackupMetadata extends Equatable {
  /// Drive file id (opaque) — used to download/restore/delete this
  /// backup.
  final String driveFileId;

  /// When this backup was created (UTC), as recorded in the archive's
  /// own manifest at the time it was built — NOT Drive's own
  /// `createdTime`, so this stays correct even if Drive's metadata
  /// clock differs.
  final DateTime createdAt;

  /// Number of diary entries captured in this backup.
  final int entryCount;

  /// Size of the backup file in bytes (0 if unknown).
  final int sizeBytes;

  const CloudBackupMetadata({
    required this.driveFileId,
    required this.createdAt,
    required this.entryCount,
    this.sizeBytes = 0,
  });

  @override
  List<Object?> get props => [driveFileId, createdAt, entryCount, sizeBytes];
}