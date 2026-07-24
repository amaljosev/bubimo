// lib/features/app_lock/domain/usecases/verify_pin.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_failure.dart';
import '../repositories/app_lock_repository.dart';

/// Verifies an entered PIN against the stored one.
class VerifyPin {
  const VerifyPin(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, Unit> call(String pin) => _repository.verifyPin(pin);
}
