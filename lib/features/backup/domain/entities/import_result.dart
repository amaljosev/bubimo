// lib/features/backup/domain/entities/import_result.dart

import 'package:equatable/equatable.dart';

/// Outcome of a successful import operation.
///
/// Every entry that made it into the bundle's `data/diary_entries.json`
/// is imported as a brand-new row with a freshly generated id (see
/// `BackupLocalDataSource`'s doc comment) — nothing is ever overwritten
/// or merged with an existing entry, so there is no "conflict" outcome
/// to report here. [skippedCount] instead reflects entries that were
/// individually malformed in the bundle itself (corrupt JSON for that
/// one record) and were skipped so one bad record can't fail the whole
/// import — mirroring the same per-record fault isolation
/// [DiaryEntryModel]'s `_decodeStickers`/`_decodeOverlayImages` already
/// use for corrupt data within a single entry.
class ImportResult extends Equatable {
  /// Number of diary entries successfully imported as new entries.
  final int importedCount;

  /// Number of records in the bundle that couldn't be parsed and were
  /// skipped, rather than failing the entire import.
  final int skippedCount;

  const ImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  @override
  List<Object?> get props => [importedCount, skippedCount];
}