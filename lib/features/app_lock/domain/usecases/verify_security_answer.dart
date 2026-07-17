// lib/features/app_lock/domain/usecases/verify_security_answer.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Verifies an answer entered on the recovery screen against the stored
/// answer hash. Used as the recovery path when PIN/pattern is forgotten
/// or biometric auth is unavailable.
class VerifySecurityAnswer {
  final AppLockRepository repository;

  VerifySecurityAnswer(this.repository);

  Future<Either<Failure, bool>> call(String answer) {
    return repository.verifySecurityAnswer(answer);
  }
}