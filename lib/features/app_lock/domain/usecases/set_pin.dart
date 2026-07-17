// lib/features/app_lock/domain/usecases/set_pin.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Validates and stores a new PIN during PIN setup.
///
/// Validation (length, digits-only) is expected to have already happened
/// in LockSetupBloc before calling this — this use case hashes and
/// persists whatever String it's given.
class SetPin {
  final AppLockRepository repository;

  SetPin(this.repository);

  Future<Either<Failure, Unit>> call(String pin) {
    return repository.setPin(pin);
  }
}