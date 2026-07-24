// lib/features/cloud_backup/data/datasources/google_drive_datasource.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;

import '../../../../core/error/exceptions.dart';
import 'google_auth_datasource.dart';

/// Name every uploaded backup file uses in Drive's `appDataFolder`.
/// Fixed (not timestamped) since there's only ever one cloud backup at
/// a time — a new backup overwrites this one rather than creating a
/// second file with a different name.
const String _kCloudBackupFileName = 'bubimo_cloud_backup.bubimo';

/// Raw Google Drive `appDataFolder` access for cloud backup.
///
/// Much simpler than a general-purpose Drive integration would be,
/// because there is exactly ONE file this app ever reads or writes:
/// the single `.bubimo` archive `CloudBackupRepositoryImpl` builds via
/// `BackupLocalDataSource.buildBackupArchive()`. No per-image uploads,
/// no manifest/image-file pairing to keep consistent — the archive
/// already contains everything (entries + every referenced media file)
/// in one blob, the same as local export.
///
/// No error-wrapping here beyond mapping Drive's own error shape into
/// this app's exception types — `CloudBackupRepositoryImpl` converts
/// those into `Failure`s, matching every other data source in this
/// app.
class GoogleDriveDataSource {
  final GoogleAuthDataSource authDataSource;
  const GoogleDriveDataSource(this.authDataSource);

  static const String _appDataFolder = 'appDataFolder';

  Future<drive.DriveApi> _api() async {
    final client = await authDataSource.authClient();
    return drive.DriveApi(client);
  }

  /// Finds the current cloud backup file, if one exists. Returns null
  /// if none is present (first backup ever, or previously deleted).
  Future<drive.File?> findCurrentBackupFile() {
    return _run(() async {
      final api = await _api();
      final result = await api.files.list(
        spaces: _appDataFolder,
        q: "name = '$_kCloudBackupFileName'",
        $fields: 'files(id,name,size,createdTime,appProperties)',
        pageSize: 10,
      );
      final files = result.files ?? const [];
      return files.isEmpty ? null : files.first;
    });
  }

  /// Uploads [bytes] as the cloud backup file, tagging it with
  /// [appProperties] (createdAt/entryCount, mirroring
  /// [BackupManifest]'s own fields) so [findCurrentBackupFile]'s caller
  /// can show metadata without downloading and unzipping the whole
  /// archive just to read its manifest.
  Future<drive.File> uploadBackup({
    required Uint8List bytes,
    required Map<String, String> appProperties,
  }) {
    return _run(() async {
      final api = await _api();
      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/zip',
      );
      final fileMeta = drive.File()
        ..name = _kCloudBackupFileName
        ..parents = [_appDataFolder]
        ..appProperties = appProperties;

      return api.files.create(
        fileMeta,
        uploadMedia: media,
        $fields: 'id,name,size,createdTime,appProperties',
      );
    });
  }

  Future<Uint8List> downloadBackup(String driveFileId) {
    return _run(() async {
      final api = await _api();
      final media =
          await api.files.get(
                driveFileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final chunks = <int>[];
      await for (final chunk in media.stream) {
        chunks.addAll(chunk);
      }
      return Uint8List.fromList(chunks);
    });
  }

  Future<void> deleteFile(String driveFileId) {
    return _run(() async {
      final api = await _api();
      await api.files.delete(driveFileId);
    });
  }

  // ── Error handling ────────────────────────────────────────────────

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on drive.DetailedApiRequestError catch (e) {
      throw _mapDriveError(e);
    } on AuthExpiredException {
      rethrow;
    } on AuthException {
      rethrow;
    } on AuthCancelledException {
      rethrow;
    } on SocketException {
      throw const CloudBackupException(
        message: 'No internet connection.',
      );
    } on TimeoutException {
      throw const CloudBackupException(
        message: 'The request to Google Drive timed out.',
      );
    } catch (e) {
      throw CloudBackupException(message: 'Unexpected Drive error: $e');
    }
  }

  Exception _mapDriveError(drive.DetailedApiRequestError e) {
    final status = e.status;
    final reason = (e.errors.isNotEmpty ? e.errors.first.reason : null) ?? '';

    if (status == 401) {
      return const AuthExpiredException(message: 'Drive session expired.');
    }
    if (status == 403) {
      switch (reason) {
        case 'storageQuotaExceeded':
          return const CloudBackupException(
            message:
                'Google Drive storage is full. Free up space and try '
                'again.',
          );
        case 'rateLimitExceeded':
        case 'userRateLimitExceeded':
          return const CloudBackupException(
            message: 'Too many requests. Please try again shortly.',
          );
        case 'domainPolicy':
          return const CloudBackupException(
            message: 'Your organization has blocked Drive access.',
          );
        default:
          return CloudBackupException(
            message: 'Drive denied the request: $reason',
          );
      }
    }
    if (status != null && status >= 500) {
      return CloudBackupException(message: 'Drive server error ($status).');
    }
    return CloudBackupException(message: 'Drive error ($status): ${e.message}');
  }
}