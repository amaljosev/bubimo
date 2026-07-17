// lib/features/app_lock/domain/usecases/verify_pin.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Verifies a PIN entered on the lock gate screen against the stored hash.
class VerifyPin {
  final AppLockRepository repository;

  VerifyPin(this.repository);

  Future<Either<Failure, bool>> call(String pin) {
    return repository.verifyPin(pin);
  }
}