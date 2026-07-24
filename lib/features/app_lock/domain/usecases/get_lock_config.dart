// lib/features/app_lock/domain/usecases/get_lock_config.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_config.dart';
import '../entities/lock_failure.dart';
import '../repositories/app_lock_repository.dart';

/// Reads the persisted lock configuration.
class GetLockConfig {
  const GetLockConfig(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, LockConfig> call() => _repository.getLockConfig();
}
