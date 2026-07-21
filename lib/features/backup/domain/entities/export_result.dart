// lib/features/backup/domain/entities/export_result.dart

import 'package:equatable/equatable.dart';

/// Outcome of a successful export operation — everything the
/// presentation layer needs to show a confirmation to the user without
/// reaching back into the data layer.
class ExportResult extends Equatable {
  /// Absolute path to the created `.bubimo` file on disk.
  final String filePath;

  /// Number of diary entries included in the export.
  final int entryCount;

  /// Total size of the created file, in bytes — shown to the user as a
  /// sanity signal ("that seems too small/large for N entries") rather
  /// than for any functional purpose.
  final int fileSizeBytes;

  /// True if the file was saved to the public Downloads directory;
  /// false if [MediaStorageService]/`path_provider` fell back to an
  /// app-private directory (see `BackupLocalDataSource`'s doc comment
  /// on why that fallback exists). The presentation layer uses this to
  /// phrase the confirmation message accurately — a file only the app
  /// itself can browse to needs different guidance than one sitting in
  /// the user's regular Downloads folder.
  final bool savedToPublicDownloads;

  const ExportResult({
    required this.filePath,
    required this.entryCount,
    required this.fileSizeBytes,
    required this.savedToPublicDownloads,
  });

  @override
  List<Object?> get props =>
      [filePath, entryCount, fileSizeBytes, savedToPublicDownloads];
}