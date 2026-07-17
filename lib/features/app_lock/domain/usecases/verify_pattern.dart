// lib/features/app_lock/domain/usecases/verify_pattern.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Verifies a pattern drawn on the lock gate screen against the stored hash.
class VerifyPattern {
  final AppLockRepository repository;

  VerifyPattern(this.repository);

  Future<Either<Failure, bool>> call(String pattern) {
    return repository.verifyPattern(pattern);
  }
}