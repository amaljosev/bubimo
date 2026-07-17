// lib/features/app_lock/domain/usecases/set_security_question.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/security_question.dart';
import '../repositories/app_lock_repository.dart';

/// Stores the single security question + hashed answer during setup.
///
/// [question] must already have its answer hashed (LockSetupBloc builds
/// the SecurityQuestion via HashingUtils before calling this) — this use
/// case only persists it.
class SetSecurityQuestion {
  final AppLockRepository repository;

  SetSecurityQuestion(this.repository);

  Future<Either<Failure, Unit>> call(SecurityQuestion question) {
    return repository.setSecurityQuestion(question);
  }
}