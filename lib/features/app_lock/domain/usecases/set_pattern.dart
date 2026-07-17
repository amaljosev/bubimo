// lib/features/app_lock/domain/usecases/set_pattern.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Validates and stores a new pattern during pattern setup.
///
/// [pattern] is expected as a dash-separated string of node indices
/// (e.g. "0-1-2-5-8"), already validated for minimum length by
/// LockSetupBloc before this is called.
class SetPattern {
  final AppLockRepository repository;

  SetPattern(this.repository);

  Future<Either<Failure, Unit>> call(String pattern) {
    return repository.setPattern(pattern);
  }
}