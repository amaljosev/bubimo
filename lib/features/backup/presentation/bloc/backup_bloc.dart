// lib/features/backup/presentation/bloc/backup/backup_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/export_result.dart';
import '../../domain/entities/import_result.dart';
import '../../domain/usecases/export_diary_backup.dart';
import '../../domain/usecases/import_diary_backup.dart';

part 'backup_event.dart';
part 'backup_state.dart';

/// Drives the combined Import & Export screen.
///
/// Deliberately one bloc for both operations rather than two separate
/// blocs — export and import share the exact same
/// idle/running/success/failure state shape, and the screen presents
/// them as two actions on one page (not two separate routes), so
/// splitting them would mean two blocs independently reinventing
/// identical status-tracking for no separation-of-concerns benefit.
class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final ExportDiaryBackup exportDiaryBackup;
  final ImportDiaryBackup importDiaryBackup;

  BackupBloc({
    required this.exportDiaryBackup,
    required this.importDiaryBackup,
  }) : super(const BackupState()) {
    on<BackupExportRequested>(_onExportRequested);
    on<BackupImportRequested>(_onImportRequested);
    on<BackupResultAcknowledged>(_onResultAcknowledged);
  }

  Future<void> _onExportRequested(
    BackupExportRequested event,
    Emitter<BackupState> emit,
  ) async {
    // Guard against a duplicate tap firing a second export while one is
    // already running — same guard pattern as DiaryFormBloc._onSubmitted.
    if (state.isBusy) return;

    emit(state.cleared(status: BackupStatus.exporting));

    final result = await exportDiaryBackup();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: BackupStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (exportResult) => emit(
        state.copyWith(
          status: BackupStatus.exportSuccess,
          exportResult: exportResult,
        ),
      ),
    );
  }

  Future<void> _onImportRequested(
    BackupImportRequested event,
    Emitter<BackupState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.cleared(status: BackupStatus.importing));

    final result = await importDiaryBackup(event.filePath);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: BackupStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (importResult) => emit(
        state.copyWith(
          status: BackupStatus.importSuccess,
          importResult: importResult,
        ),
      ),
    );
  }

  void _onResultAcknowledged(
    BackupResultAcknowledged event,
    Emitter<BackupState> emit,
  ) {
    emit(state.cleared(status: BackupStatus.idle));
  }
}