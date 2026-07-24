// lib/features/app_lock/presentation/bloc/lock_state.dart

part of 'lock_bloc.dart';

enum VerificationStatus { idle, inProgress, success, failure }

// Named AppLockState, not LockState — `LockState` collides with
// Flutter's own LockState (from package:flutter/src/widgets/shortcuts.dart,
// exported via material.dart; it represents keyboard lock-key state
// like CapsLock/NumLock) and both would otherwise be visible wherever
// this file's `part of` library and `package:flutter/material.dart`
// are imported together, which is every page in this feature.
class AppLockState extends Equatable {
  const AppLockState({
    required this.lockType,
    required this.isLoading,
    required this.isLocked,
    required this.verificationStatus,
    this.securityQuestion,
    this.biometricEnabled = false,
    this.verificationError,
    this.loadError,
  });

  factory AppLockState.initial() => const AppLockState(
    lockType: LockType.none,
    isLoading: false,
    isLocked: false,
    verificationStatus: VerificationStatus.idle,
  );

  /// The currently configured lock type.
  final LockType lockType;

  /// True while settings are being loaded or changed.
  final bool isLoading;

  /// True when the app should be showing a lock/verify screen right now.
  final bool isLocked;

  /// Status of the in-flight or most recent verification attempt.
  final VerificationStatus verificationStatus;

  /// The stored security question text, when [lockType] is
  /// [LockType.securityQuestion]. Never carries the answer.
  final String? securityQuestion;

  /// Independent of [lockType] — see LockConfig.biometricEnabled's doc
  /// comment. True means the PIN/security-question verify screens
  /// should also offer a biometric shortcut button.
  final bool biometricEnabled;

  /// User-facing message for the most recent verification failure.
  final String? verificationError;

  /// User-facing message for the most recent settings load/save failure.
  final String? loadError;

  bool get verificationInProgress =>
      verificationStatus == VerificationStatus.inProgress;

  /// True when the PIN/security-question verify screen should render a
  /// "use biometric instead" shortcut button.
  bool get showsBiometricShortcut =>
      biometricEnabled &&
      (lockType == LockType.pin || lockType == LockType.securityQuestion);

  AppLockState copyWith({
    LockType? lockType,
    bool? isLoading,
    bool? isLocked,
    VerificationStatus? verificationStatus,
    String? securityQuestion,
    bool? biometricEnabled,
    String? verificationError,
    String? loadError,
  }) {
    return AppLockState(
      lockType: lockType ?? this.lockType,
      isLoading: isLoading ?? this.isLoading,
      isLocked: isLocked ?? this.isLocked,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      verificationError: verificationError,
      loadError: loadError,
    );
  }

  @override
  List<Object?> get props => [
    lockType,
    isLoading,
    isLocked,
    verificationStatus,
    securityQuestion,
    biometricEnabled,
    verificationError,
    loadError,
  ];
}