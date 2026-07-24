// lib/features/app_lock/domain/usecases/set_biometric_enabled.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_failure.dart';
import '../repositories/app_lock_repository.dart';

/// Turns the "also allow biometric" shortcut on/off, independent of the
/// active LockType. See AppLockRepository.setBiometricEnabled's doc
/// comment for when this is meaningful.
class SetBiometricEnabled {
  const SetBiometricEnabled(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, Unit> call(bool enabled) =>
      _repository.setBiometricEnabled(enabled);
}