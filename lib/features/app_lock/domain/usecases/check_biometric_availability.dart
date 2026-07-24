// lib/features/app_lock/domain/usecases/check_biometric_availability.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_failure.dart';
import '../repositories/app_lock_repository.dart';

/// Checks whether biometric authentication can be used on this device
/// right now (hardware present, something enrolled, OS-supported).
class CheckBiometricAvailability {
  const CheckBiometricAvailability(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, bool> call() => _repository.isBiometricAvailable();
}
