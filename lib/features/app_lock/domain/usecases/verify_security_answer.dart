// lib/features/app_lock/domain/usecases/verify_security_answer.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_failure.dart';
import '../repositories/app_lock_repository.dart';

/// Verifies an entered security answer against the stored one.
class VerifySecurityAnswer {
  const VerifySecurityAnswer(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, Unit> call(String answer) =>
      _repository.verifySecurityAnswer(answer);
}
