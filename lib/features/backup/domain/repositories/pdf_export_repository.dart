// lib/features/backup/domain/repositories/pdf_export_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/pdf_export_result.dart';

/// Contract for generating a human-readable PDF of every diary entry,
/// implemented by `PdfExportRepositoryImpl` in the data layer.
///
/// Kept separate from [BackupRepository] rather than a third method on
/// it — a `.bubimo` backup and a PDF export are different concerns
/// (round-trippable app data vs. a one-way human-readable document),
/// matching this codebase's convention of one repository per distinct
/// capability (e.g. [DiaryRepository] vs [StickerRepository]) rather
/// than grouping unrelated operations onto one interface.
abstract class PdfExportRepository {
  /// Generates a PDF containing every non-deleted diary entry's date,
  /// title, and plain-text body (no images), and saves it to disk.
  Future<Either<Failure, PdfExportResult>> exportPdf();
}