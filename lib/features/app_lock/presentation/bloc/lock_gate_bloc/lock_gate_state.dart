// lib/features/app_lock/presentation/bloc/lock_gate_bloc/lock_gate_state.dart

part of 'lock_gate_bloc.dart';

sealed class LockGateState extends Equatable {
  const LockGateState();

  @override
  List<Object?> get props => [];
}

class LockGateInitial extends LockGateState {
  const LockGateInitial();
}

/// Biometric prompt (system bottom sheet) is up or about to appear.
/// The screen renders a dimmed/blurred background behind it via
/// LockGateBackground so there's no dead frame while the OS sheet
/// animates in.
class LockGateAwaitingBiometric extends LockGateState {
  const LockGateAwaitingBiometric();
}

/// PIN or pattern entry is active.
class LockGateAwaitingInput extends LockGateState {
  final LockMethod method;

  const LockGateAwaitingInput(this.method);

  @override
  List<Object?> get props => [method];
}

/// The security-question recovery form is active.
class LockGateAwaitingSecurityAnswer extends LockGateState {
  const LockGateAwaitingSecurityAnswer();
}

/// A distinguishable reason for LockGateError, so the UI can choose
/// the right recovery action (retry vs. fallback vs. just re-enter).
enum LockGateErrorReason {
  wrongPin,
  wrongPattern,
  wrongSecurityAnswer,
  biometricFailed,
  biometricUnavailable,
  biometricCancelled,
}

class LockGateError extends LockGateState {
  final LockGateErrorReason reason;
  final String message;

  /// The method active before the error, so a "try again" action knows
  /// what to retry.
  final LockMethod method;

  const LockGateError({
    required this.reason,
    required this.message,
    required this.method,
  });

  bool get canRetryBiometric =>
      reason == LockGateErrorReason.biometricFailed ||
      reason == LockGateErrorReason.biometricCancelled;

  bool get canOfferSecurityQuestionFallback =>
      reason != LockGateErrorReason.wrongSecurityAnswer;

  @override
  List<Object?> get props => [reason, message, method];
}

class LockGateUnlocked extends LockGateState {
  const LockGateUnlocked();
}