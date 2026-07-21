// lib/features/backup/domain/entities/backup_manifest.dart

import 'package:equatable/equatable.dart';

/// Parsed contents of a `.bubimo` bundle's `manifest.json`.
///
/// The manifest is read and validated BEFORE any diary entry data is
/// touched or any database write happens — see
/// `BackupLocalDataSource.importBackup`. This is what lets an
/// unreadable/foreign/too-new file be rejected cleanly with a specific
/// message, rather than partially importing garbage and leaving the
/// database in a half-updated state.
class BackupManifest extends Equatable {
  /// Version of the `.bubimo` bundle format itself (NOT the app's own
  /// version) — starts at 1. Incremented only when the bundle's
  /// internal structure changes (e.g. a new top-level file is added, or
  /// `diary_entries.json`'s shape changes) in a way that an older app
  /// build couldn't parse correctly. This is deliberately independent
  /// of [appVersion] — the app's version number can (and will) change
  /// far more often than the bundle format itself does.
  final int formatVersion;

  /// When this bundle was created, per the exporting device's clock.
  final DateTime exportedAt;

  /// The exporting app's own version string (from pubspec.yaml), shown
  /// to the user for their own reference — purely informational, not
  /// used for any compatibility decision.
  final String appVersion;

  /// Number of diary entries the manifest claims are included. Cross-
  /// checked against the actual parsed count from
  /// `data/diary_entries.json` before import proceeds — a mismatch
  /// indicates a corrupted or tampered bundle.
  final int entryCount;

  const BackupManifest({
    required this.formatVersion,
    required this.exportedAt,
    required this.appVersion,
    required this.entryCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': formatVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'appVersion': appVersion,
      'entryCount': entryCount,
    };
  }

  /// Throws [FormatException] if [json] is missing a required key or a
  /// value is the wrong type — callers should catch this and translate
  /// it into an [ImportExportFailure] with a user-facing message, same
  /// pattern as `DiaryEntryModel.fromMap` assumes well-formed input and
  /// lets its caller handle malformed data.
  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final formatVersion = json['formatVersion'];
    final exportedAt = json['exportedAt'];
    final appVersion = json['appVersion'];
    final entryCount = json['entryCount'];

    if (formatVersion is! int) {
      throw const FormatException(
        'manifest.json is missing or has an invalid "formatVersion".',
      );
    }
    if (exportedAt is! String) {
      throw const FormatException(
        'manifest.json is missing or has an invalid "exportedAt".',
      );
    }
    if (appVersion is! String) {
      throw const FormatException(
        'manifest.json is missing or has an invalid "appVersion".',
      );
    }
    if (entryCount is! int) {
      throw const FormatException(
        'manifest.json is missing or has an invalid "entryCount".',
      );
    }

    final parsedDate = DateTime.tryParse(exportedAt);
    if (parsedDate == null) {
      throw const FormatException(
        'manifest.json\'s "exportedAt" is not a valid ISO-8601 date.',
      );
    }

    return BackupManifest(
      formatVersion: formatVersion,
      exportedAt: parsedDate,
      appVersion: appVersion,
      entryCount: entryCount,
    );
  }

  @override
  List<Object?> get props => [formatVersion, exportedAt, appVersion, entryCount];
}