// lib/core/utils/downloads_directory_resolver.dart

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves where a user-facing exported file (a `.bubimo` backup, a
/// PDF export, or anything else meant to land in the device's regular
/// Downloads folder) should be saved, and whether that resolution
/// actually reached the public, user-visible Downloads directory.
///
/// Tries `getDownloadsDirectory()` first — Android support for this was
/// only added in `path_provider_android` 2.2.0+ (this project currently
/// resolves 2.3.1, confirmed via `flutter pub deps`, so the primary
/// path is expected to succeed). Falls back to a clearly named
/// subfolder under the app's own documents directory if unavailable for
/// any reason (an older resolved version on a different machine/CI, or
/// any other platform-reported failure) — this keeps every export
/// feature working either way, at the cost of the fallback file only
/// being reachable from within the app itself rather than the device's
/// regular Files app. The returned bool tells the presentation layer
/// which case happened, so the confirmation message shown to the user
/// stays accurate either way.
///
/// Shared by `BackupLocalDataSource` (`.bubimo` export) and
/// `PdfExportDataSource` (PDF export) — both need the exact same
/// "prefer Downloads, fall back to an app-private folder" behavior, and
/// duplicating it per data source would risk the two silently drifting
/// apart over time.
Future<(Directory, bool)> resolveDownloadsDirectory({
  String fallbackSubfolderName = 'exported_files',
}) async {
  try {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return (downloadsDir, true);
    }
  } catch (_) {
    // Falls through to the app-private fallback below.
  }

  final appDocsDir = await getApplicationDocumentsDirectory();
  final fallbackDir = Directory(
    p.join(appDocsDir.path, fallbackSubfolderName),
  );
  if (!await fallbackDir.exists()) {
    await fallbackDir.create(recursive: true);
  }
  return (fallbackDir, false);
}