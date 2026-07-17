// lib/features/app_lock/domain/usecases/set_lock_method.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/lock_method.dart';
import '../repositories/app_lock_repository.dart';

/// Sets [LockMethod] as the active lock method. Called after the user has
/// already completed setup for that method (PIN saved, pattern saved,
/// biometric/device credential verified as available).
class SetLockMethod {
  final AppLockRepository repository;

  SetLockMethod(this.repository);

  Future<Either<Failure, Unit>> call(LockMethod method) {
    return repository.setActiveLockMethod(method);
  }
}