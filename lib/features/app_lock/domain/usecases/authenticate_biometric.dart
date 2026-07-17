// lib/features/app_lock/domain/usecases/authenticate_biometric.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_lock_repository.dart';

/// Triggers the device biometric prompt (fingerprint/face) via local_auth.
///
/// Returns `true` on successful auth, `false` on user cancellation or
/// failed match. A [Failure] is only surfaced for setup/hardware issues
/// (no biometrics enrolled, hardware unavailable) — LockGateBloc uses
/// that distinction to decide whether to show a retry vs. a
/// "biometrics unavailable, use security question" error state.
class AuthenticateBiometric {
  final AppLockRepository repository;

  AuthenticateBiometric(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.authenticateBiometric();
  }
}