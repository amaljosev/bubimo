// lib/features/app_lock/domain/usecases/disable_lock.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Turns off app lock entirely, from the listing/settings screen.
///
/// This only deactivates the lock — it does not clear stored PIN/pattern/
/// security question data, so re-enabling a previously configured method
/// does not require re-setup.
class DisableLock {
  final AppLockRepository repository;

  DisableLock(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.disableLock();
  }
}