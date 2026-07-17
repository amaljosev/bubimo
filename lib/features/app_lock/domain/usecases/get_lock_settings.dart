// lib/features/app_lock/domain/usecases/get_lock_settings.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/lock_method.dart';
import '../repositories/app_lock_repository.dart';

/// Fetches the currently active lock method for the listing/settings screen.
class GetLockSettings {
  final AppLockRepository repository;

  GetLockSettings(this.repository);

  Future<Either<Failure, LockMethod>> call() {
    return repository.getActiveLockMethod();
  }
}