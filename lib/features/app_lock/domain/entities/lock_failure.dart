// lib/features/app_lock/domain/entities/lock_failure.dart

import 'package:equatable/equatable.dart';

/// Error channel type used across the feature's `Either<LockFailure, T>`
/// return values (fpdart — already a project dependency). Keeping this
/// in the domain layer means use cases never leak platform exceptions
/// (PlatformException, DatabaseException, etc.) up to the bloc.
sealed class LockFailure extends Equatable {
  const LockFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Reading from or writing to the local database or secure storage failed.
class StorageFailure extends LockFailure {
  const StorageFailure([super.message = 'Could not access local storage.']);
}

/// The device has no biometric hardware, or none enrolled, or the OS
/// reported it as unavailable right now.
class BiometricUnavailableFailure extends LockFailure {
  const BiometricUnavailableFailure([
    super.message = 'Biometric authentication is not available on this device.',
  ]);
}

/// The user cancelled, failed, or the OS-level biometric prompt errored.
class BiometricAuthFailure extends LockFailure {
  const BiometricAuthFailure([
    super.message = 'Authentication was cancelled or failed.',
  ]);
}

/// Entered PIN did not match the stored one.
class IncorrectPinFailure extends LockFailure {
  const IncorrectPinFailure([super.message = 'Incorrect PIN.']);
}

/// Submitted security answer did not match the stored one.
class IncorrectAnswerFailure extends LockFailure {
  const IncorrectAnswerFailure([super.message = 'Incorrect answer.']);
}

/// Tried to verify against a lock type that has nothing configured yet.
class NotConfiguredFailure extends LockFailure {
  const NotConfiguredFailure([super.message = 'This lock method is not set up.']);
}
