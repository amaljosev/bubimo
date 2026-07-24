// lib/features/cloud_backup/presentation/bloc/cloud_backup_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cloud_backup_metadata.dart';
import '../../domain/repositories/cloud_backup_repository.dart';

part 'cloud_backup_event.dart';
part 'cloud_backup_state.dart';

/// Drives the cloud backup screen — Google sign-in, backing up to
/// Drive, checking/restoring the current cloud backup, and signing
/// out. One bloc for all of it, matching this app's established
/// pattern of one bloc per screen rather than one per operation (see
/// `BackupBloc`'s doc comment for the same reasoning applied to the
/// local `.bubimo` Import & Export screen).
class CloudBackupBloc extends Bloc<CloudBackupEvent, CloudBackupState> {
  final CloudBackupRepository repository;

  CloudBackupBloc({required this.repository})
      : super(const CloudBackupState()) {
    on<CloudBackupSignInRequested>(_onSignIn);
    on<CloudBackupSilentSignInRequested>(_onSilentSignIn);
    on<CloudBackupSignOutRequested>(_onSignOut);
    on<CloudBackupNowRequested>(_onBackupNow);
    on<CloudBackupStatusRequested>(_onStatusRequested);
    on<CloudBackupRestoreRequested>(_onRestore);
    on<CloudBackupDeleteRequested>(_onDelete);
    on<_CloudBackupProgressUpdated>(_onProgress);
  }

  // ── Auth ──────────────────────────────────────────────────────────

  Future<void> _onSignIn(
    CloudBackupSignInRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    emit(state.copyWith(status: CloudBackupStatus.busy, message: null));
    final result = await repository.signIn();

    result.fold(
      (failure) {
        // The user simply dismissed the account picker — return to
        // idle silently rather than showing this as an error.
        if (failure is AuthCancelledFailure) {
          emit(
            state.copyWith(status: CloudBackupStatus.idle, message: null),
          );
          return;
        }
        emit(
          state.copyWith(
            status: CloudBackupStatus.failure,
            isSignedIn: false,
            message: failure.message,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(status: CloudBackupStatus.success, isSignedIn: true),
        );
        add(const CloudBackupStatusRequested());
      },
    );
  }

  Future<void> _onSilentSignIn(
    CloudBackupSilentSignInRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    final result = await repository.signInSilently();
    result.fold(
      (_) => emit(state.copyWith(isSignedIn: false)),
      (wasSignedIn) {
        emit(state.copyWith(isSignedIn: wasSignedIn));
        if (wasSignedIn) add(const CloudBackupStatusRequested());
      },
    );
  }

  Future<void> _onSignOut(
    CloudBackupSignOutRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    final result = await repository.signOut();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CloudBackupStatus.failure,
          message: failure.message,
        ),
      ),
      (_) => emit(
        const CloudBackupState(
          status: CloudBackupStatus.idle,
          isSignedIn: false,
        ),
      ),
    );
  }

  // ── Backup ────────────────────────────────────────────────────────

  Future<void> _onBackupNow(
    CloudBackupNowRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    if (state.isBusy) return;

    emit(
      state.copyWith(
        status: CloudBackupStatus.busy,
        message: null,
        phase: CloudBackupPhase.buildingArchive,
      ),
    );

    final result = await repository.backUpToCloud(
      onProgress: (phase) => add(_CloudBackupProgressUpdated(phase)),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CloudBackupStatus.failure,
          message: failure.message,
          phase: null,
        ),
      ),
      (meta) => emit(
        state.copyWith(
          status: CloudBackupStatus.success,
          currentBackup: meta,
          message: 'Backed up ${meta.entryCount} entries to Google Drive.',
          phase: null,
        ),
      ),
    );
  }

  Future<void> _onStatusRequested(
    CloudBackupStatusRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    final result = await repository.getCloudBackupStatus();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CloudBackupStatus.failure,
          message: failure.message,
        ),
      ),
      (meta) => emit(
        state.copyWith(
          status: CloudBackupStatus.success,
          currentBackup: meta,
          clearCurrentBackup: meta == null,
        ),
      ),
    );
  }

  // ── Restore ───────────────────────────────────────────────────────

  Future<void> _onRestore(
    CloudBackupRestoreRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    if (state.isBusy) return;

    emit(
      state.copyWith(
        status: CloudBackupStatus.busy,
        message: null,
        phase: CloudBackupPhase.downloading,
      ),
    );

    final result = await repository.restoreFromCloud(
      onProgress: (phase) => add(_CloudBackupProgressUpdated(phase)),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CloudBackupStatus.failure,
          message: failure.message,
          phase: null,
        ),
      ),
      (count) => emit(
        state.copyWith(
          status: CloudBackupStatus.success,
          restoredCount: count,
          message: 'Restored $count ${count == 1 ? 'entry' : 'entries'} '
              'to your diary.',
          phase: null,
        ),
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────

  Future<void> _onDelete(
    CloudBackupDeleteRequested event,
    Emitter<CloudBackupState> emit,
  ) async {
    emit(state.copyWith(status: CloudBackupStatus.busy, message: null));
    final result = await repository.deleteCloudBackup();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CloudBackupStatus.failure,
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: CloudBackupStatus.success,
          clearCurrentBackup: true,
          message: 'Cloud backup deleted.',
        ),
      ),
    );
  }

  // ── Progress ──────────────────────────────────────────────────────

  void _onProgress(
    _CloudBackupProgressUpdated event,
    Emitter<CloudBackupState> emit,
  ) {
    // Guards against a stale progress event arriving after the
    // operation has already resolved.
    if (state.status != CloudBackupStatus.busy) return;
    emit(state.copyWith(phase: event.phase));
  }
}