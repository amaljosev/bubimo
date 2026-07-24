// lib/features/cloud_backup/data/models/cloud_backup_manifest_model.dart

import 'package:googleapis/drive/v3.dart' as drive;

import '../../domain/entities/cloud_backup_metadata.dart';

/// Maps a Drive file's metadata/appProperties <-> [CloudBackupMetadata].
///
/// Simpler than the local `.bubimo` bundle's own manifest handling
/// ([BackupManifest]) — Drive's `appProperties` only need to carry
/// enough for [CloudBackupRepository.getCloudBackupStatus] to show a
/// summary WITHOUT downloading and unzipping the whole archive; the
/// archive's own internal `manifest.json` (built by
/// `BackupLocalDataSource.buildBackupArchive`) remains the source of
/// truth once the file is actually downloaded and restored.
class CloudBackupManifestModel {
  const CloudBackupManifestModel._();

  static Map<String, String> toAppProperties({
    required DateTime createdAt,
    required int entryCount,
  }) {
    return {
      'createdAt': createdAt.toUtc().toIso8601String(),
      'entryCount': '$entryCount',
    };
  }

  static CloudBackupMetadata fromDriveFile(drive.File file) {
    final props = file.appProperties ?? const {};
    return CloudBackupMetadata(
      driveFileId: file.id ?? '',
      createdAt:
          DateTime.tryParse(props['createdAt'] ?? '')?.toUtc() ??
          file.createdTime?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      entryCount: int.tryParse(props['entryCount'] ?? '') ?? 0,
      sizeBytes: int.tryParse(file.size ?? '') ?? 0,
    );
  }
}
