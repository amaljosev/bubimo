// lib/features/backup/domain/entities/pdf_export_result.dart

import 'package:equatable/equatable.dart';

/// Outcome of a successful "Download as PDF" export.
///
/// Distinct from [ExportResult] (the `.bubimo` backup file) — a PDF
/// export is a human-readable, one-way document for the user to read,
/// share, or print, never something the app itself reads back in. See
/// `PdfExportDataSource`'s doc comment for what the PDF actually
/// contains.
class PdfExportResult extends Equatable {
  /// Absolute path to the created `.pdf` file on disk.
  final String filePath;

  /// Number of diary entries included in the PDF.
  final int entryCount;

  /// True if the file was saved to the public Downloads directory;
  /// false if it fell back to an app-private directory — see
  /// `resolveDownloadsDirectory`'s doc comment. Mirrors
  /// [ExportResult.savedToPublicDownloads] so the presentation layer
  /// can phrase both confirmations the same way.
  final bool savedToPublicDownloads;

  const PdfExportResult({
    required this.filePath,
    required this.entryCount,
    required this.savedToPublicDownloads,
  });

  @override
  List<Object?> get props => [filePath, entryCount, savedToPublicDownloads];
}