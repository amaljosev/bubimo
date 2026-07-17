// lib/features/app_lock/presentation/bloc/lock_gate_bloc/lock_gate_event.dart

part of 'lock_gate_bloc.dart';

sealed class LockGateEvent extends Equatable {
  const LockGateEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the gate screen first mounts (app launch, or resume from
/// background if lock-on-resume is enabled). Loads the active method
/// and, for biometric, immediately triggers the system prompt.
class LockGateStarted extends LockGateEvent {
  const LockGateStarted();
}

class PinSubmitted extends LockGateEvent {
  final String pin;

  const PinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}

class PatternSubmitted extends LockGateEvent {
  final String pattern;

  const PatternSubmitted(this.pattern);

  @override
  List<Object?> get props => [pattern];
}

/// User tapped "retry" after a biometric error/cancellation, or "use
/// biometrics" from the PIN/pattern fallback option.
class BiometricRetryRequested extends LockGateEvent {
  const BiometricRetryRequested();
}

/// User tapped "use security question instead" from an error state.
class SecurityQuestionFallbackRequested extends LockGateEvent {
  const SecurityQuestionFallbackRequested();
}

class SecurityAnswerSubmitted extends LockGateEvent {
  final String answer;

  const SecurityAnswerSubmitted(this.answer);

  @override
  List<Object?> get props => [answer];
}