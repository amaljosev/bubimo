// lib/features/app_lock/domain/repositories/app_lock_repository.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/lock_method.dart';
import '../entities/security_question.dart';

/// Contract for reading/writing app lock state.
///
/// Implementations persist to the existing app settings table (no new
/// table — see migration_v1_to_v2) and never store PIN/pattern/security
/// answers as plaintext.
abstract class AppLockRepository {
  /// Returns the currently active lock method (LockMethod.none if disabled).
  Future<Either<Failure, LockMethod>> getActiveLockMethod();

  /// Sets [method] as the active lock method. Setting a new method
  /// implicitly deactivates whatever was previously active; it does not
  /// clear that method's stored credential (e.g. switching from PIN to
  /// biometric keeps the PIN hash around in case the user switches back).
  Future<Either<Failure, Unit>> setActiveLockMethod(LockMethod method);

  /// Disables app lock entirely (sets active method to LockMethod.none).
  Future<Either<Failure, Unit>> disableLock();

  /// Stores a SHA-256 hash of [pin]. Overwrites any existing PIN hash.
  Future<Either<Failure, Unit>> setPin(String pin);

  /// Compares [pin]'s hash against the stored PIN hash.
  Future<Either<Failure, bool>> verifyPin(String pin);

  /// Returns whether a PIN has been configured, regardless of whether
  /// PIN is the currently active method.
  Future<Either<Failure, bool>> hasPinConfigured();

  /// Stores a SHA-256 hash of [pattern] (pattern encoded as a String of
  /// node indices, e.g. "0-1-2-5-8"). Overwrites any existing pattern hash.
  Future<Either<Failure, Unit>> setPattern(String pattern);

  /// Compares [pattern]'s hash against the stored pattern hash.
  Future<Either<Failure, bool>> verifyPattern(String pattern);

  /// Returns whether a pattern has been configured, regardless of whether
  /// pattern is the currently active method.
  Future<Either<Failure, bool>> hasPatternConfigured();

  /// Runs device biometric authentication via local_auth.
  /// Returns true on success, false if the user cancels or fails auth.
  /// A Failure is returned only for hardware/setup errors (no biometrics
  /// enrolled, hardware unavailable, etc.) — not for a failed attempt.
  Future<Either<Failure, bool>> authenticateBiometric();

  /// Passive capability check — does NOT trigger the system prompt.
  /// Returns true only if the device has biometric hardware AND at
  /// least one biometric is enrolled. Used to decide whether to show
  /// the Biometric tile on the listing screen at all.
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Runs device credential authentication (system PIN/pattern/password)
  /// via local_auth's device credential fallback.
  Future<Either<Failure, bool>> authenticateDeviceCredential();

  /// Stores the single security question + SHA-256 hash of the answer.
  /// Overwrites any existing security question.
  Future<Either<Failure, Unit>> setSecurityQuestion(SecurityQuestion question);

  /// Returns the stored security question (question text only — answer
  /// hash is included for internal verification, never displayed).
  Future<Either<Failure, SecurityQuestion?>> getSecurityQuestion();

  /// Compares [answer]'s hash against the stored answer hash.
  Future<Either<Failure, bool>> verifySecurityAnswer(String answer);
}