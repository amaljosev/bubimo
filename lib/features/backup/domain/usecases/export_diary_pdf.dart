// lib/features/backup/domain/usecases/export_diary_pdf.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/pdf_export_result.dart';
import '../repositories/pdf_export_repository.dart';

/// Generates a human-readable PDF (date, title, body — no images) of
/// every diary entry and saves it to disk.
///
/// Usage: `await exportDiaryPdf()`.
class ExportDiaryPdf {
  final PdfExportRepository repository;

  const ExportDiaryPdf(this.repository);

  Future<Either<Failure, PdfExportResult>> call() {
    return repository.exportPdf();
  }
}