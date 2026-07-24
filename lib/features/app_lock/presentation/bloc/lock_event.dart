// lib/features/app_lock/presentation/bloc/lock_event.dart

part of 'lock_bloc.dart';

sealed class LockEvent extends Equatable {
  const LockEvent();

  @override
  List<Object?> get props => [];
}

/// Load the persisted lock config.
///
/// [isColdStart] distinguishes two very different situations that both
/// need to reload the same data:
/// - true: app startup (main.dart, before runApp) — this is the ONLY
///   time `isLocked` should be derived from whether a lock type is
///   configured, since it's the only time "app was just opened and may
///   need verification" is actually true.
/// - false (default): a mid-session refresh, e.g. AppLockSettingsPage
///   re-dispatching this in initState every time the screen opens.
///   The user is already past the lock gate in this case — reloading
///   lockType/securityQuestion/biometricEnabled must NOT also flip
///   `isLocked` back to true, or opening Settings while a lock is
///   already configured would re-lock the user out of their own
///   session on the next navigation.
class LoadLockConfig extends LockEvent {
  const LoadLockConfig({this.isColdStart = false});

  final bool isColdStart;

  @override
  List<Object?> get props => [isColdStart];
}

/// Change the active lock type. [pin] is required for [LockType.pin];
/// [question] + [answer] are required for [LockType.securityQuestion].
class SetLockType extends LockEvent {
  const SetLockType({required this.type, this.pin, this.question, this.answer});

  final LockType type;
  final String? pin;
  final String? question;
  final String? answer;

  @override
  List<Object?> get props => [type, pin, question, answer];
}

/// Turns the "also allow biometric" shortcut on/off, independent of
/// [SetLockType]. Only meaningful while lockType is pin or
/// securityQuestion, but can be dispatched regardless — the bloc
/// persists it either way, matching how the column itself is
/// independent of lock_type in storage.
class ToggleBiometric extends LockEvent {
  const ToggleBiometric(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Puts the app into a locked state (e.g. on resume from background).
class LockApp extends LockEvent {
  const LockApp();
}

/// Bypasses verification and unlocks directly.
class UnlockApp extends LockEvent {
  const UnlockApp();
}

/// Attempt to unlock with a PIN.
class VerifyPinAttempt extends LockEvent {
  const VerifyPinAttempt(this.pin);

  final String pin;

  @override
  List<Object?> get props => [pin];
}

/// Attempt to unlock with a security-question answer.
class VerifySecurityAnswerAttempt extends LockEvent {
  const VerifySecurityAnswerAttempt(this.answer);

  final String answer;

  @override
  List<Object?> get props => [answer];
}

/// Attempt to unlock with biometrics. Used both when lockType itself
/// is biometric, AND as the shortcut path when lockType is pin/
/// securityQuestion and biometricEnabled is true.
class VerifyBiometricAttempt extends LockEvent {
  const VerifyBiometricAttempt({this.reason = 'Authenticate to unlock the app'});

  final String reason;

  @override
  List<Object?> get props => [reason];
}

/// Clears verification status/error back to idle — call after consuming
/// a failure (e.g. after showing a snackbar or shake animation).
class ResetVerification extends LockEvent {
  const ResetVerification();
}