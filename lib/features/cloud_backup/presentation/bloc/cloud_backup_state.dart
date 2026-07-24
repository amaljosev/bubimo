// lib/features/cloud_backup/presentation/bloc/cloud_backup_state.dart

part of 'cloud_backup_bloc.dart';

enum CloudBackupStatus {
  /// No operation in progress.
  idle,

  /// Sign-in, backup, restore, delete, or status check in progress.
  busy,

  /// The most recent operation succeeded — see whichever result field
  /// is relevant to what just ran.
  success,

  /// The most recent operation failed — see [CloudBackupState.message].
  failure,
}

extension CloudBackupPhaseLabel on CloudBackupPhase {
  String get label {
    switch (this) {
      case CloudBackupPhase.buildingArchive:
        return 'Preparing your diary…';
      case CloudBackupPhase.uploading:
        return 'Uploading to Google Drive…';
      case CloudBackupPhase.downloading:
        return 'Downloading from Google Drive…';
      case CloudBackupPhase.restoring:
        return 'Restoring entries…';
    }
  }
}

class CloudBackupState extends Equatable {
  final CloudBackupStatus status;
  final bool isSignedIn;

  /// The current cloud backup, if one exists — refreshed after sign-in
  /// and after every successful backup/restore/delete.
  final CloudBackupMetadata? currentBackup;

  /// Set after a successful restore, so the UI can show "Restored N
  /// entries."
  final int? restoredCount;

  final String? message;
  final CloudBackupPhase? phase;

  const CloudBackupState({
    this.status = CloudBackupStatus.idle,
    this.isSignedIn = false,
    this.currentBackup,
    this.restoredCount,
    this.message,
    this.phase,
  });

  bool get isBusy => status == CloudBackupStatus.busy;

  CloudBackupState copyWith({
    CloudBackupStatus? status,
    bool? isSignedIn,
    CloudBackupMetadata? currentBackup,
    bool clearCurrentBackup = false,
    int? restoredCount,
    String? message,
    CloudBackupPhase? phase,
  }) {
    return CloudBackupState(
      status: status ?? this.status,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      currentBackup: clearCurrentBackup
          ? null
          : (currentBackup ?? this.currentBackup),
      restoredCount: restoredCount ?? this.restoredCount,
      message: message,
      phase: phase,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isSignedIn,
        currentBackup,
        restoredCount,
        message,
        phase,
      ];
}