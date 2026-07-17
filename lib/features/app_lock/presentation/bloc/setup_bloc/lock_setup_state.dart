// lib/features/app_lock/presentation/bloc/setup_bloc/lock_setup_state.dart

part of 'lock_setup_bloc.dart';

sealed class LockSetupState extends Equatable {
  const LockSetupState();

  @override
  List<Object?> get props => [];
}

/// Waiting for the first PIN/pattern entry.
class LockSetupAwaitingFirstEntry extends LockSetupState {
  const LockSetupAwaitingFirstEntry();
}

/// First entry captured, waiting for confirmation entry.
class LockSetupAwaitingConfirmation extends LockSetupState {
  const LockSetupAwaitingConfirmation();
}

/// Confirmation didn't match the first entry — UI should show an
/// error and offer restart.
class LockSetupMismatch extends LockSetupState {
  const LockSetupMismatch();
}

/// PIN/pattern/security question saved successfully.
class LockSetupSuccess extends LockSetupState {
  const LockSetupSuccess();
}

class LockSetupError extends LockSetupState {
  final String message;

  const LockSetupError(this.message);

  @override
  List<Object?> get props => [message];
}