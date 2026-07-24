// lib/features/app_lock/domain/usecases/authenticate_with_biometrics.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_failure.dart';
import '../repositories/app_lock_repository.dart';

/// Triggers the OS biometric prompt and reports whether it succeeded.
class AuthenticateWithBiometrics {
  const AuthenticateWithBiometrics(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, bool> call({
    String reason = 'Authenticate to unlock the app',
  }) {
    return _repository.authenticateWithBiometrics(reason: reason);
  }
}
