// lib/features/app_lock/presentation/bloc/setup_bloc/lock_setup_event.dart

part of 'lock_setup_bloc.dart';

sealed class LockSetupEvent extends Equatable {
  const LockSetupEvent();

  @override
  List<Object?> get props => [];
}

/// First entry of PIN or pattern (the "create" step).
class SetupFirstEntrySubmitted extends LockSetupEvent {
  final String value;

  const SetupFirstEntrySubmitted(this.value);

  @override
  List<Object?> get props => [value];
}

/// Second entry of PIN or pattern (the "confirm" step) — compared
/// against the first entry.
class SetupConfirmationSubmitted extends LockSetupEvent {
  final String value;

  const SetupConfirmationSubmitted(this.value);

  @override
  List<Object?> get props => [value];
}

/// Resets back to the first-entry step (e.g. after a mismatch, user
/// taps "try again").
class SetupRestarted extends LockSetupEvent {
  const SetupRestarted();
}

/// Security question setup: preset selected or custom question typed,
/// plus the answer.
class SecurityQuestionSubmitted extends LockSetupEvent {
  final String question;
  final String answer;

  const SecurityQuestionSubmitted({
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [question, answer];
}