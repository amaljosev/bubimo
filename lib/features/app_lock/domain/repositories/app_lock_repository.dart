// lib/features/app_lock/domain/repositories/app_lock_repository.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_config.dart';
import '../entities/lock_failure.dart';
import '../entities/lock_type.dart';

/// Boundary between the app-lock domain and everything platform- or
/// storage-specific (sqflite for the app_settings row, local_auth for
/// biometrics). Use cases only ever talk to this interface, never to
/// the datasource directly.
abstract class AppLockRepository {
  /// Reads the currently persisted lock configuration.
  TaskEither<LockFailure, LockConfig> getLockConfig();

  /// Switches the active lock type. [pin] is required when [type] is
  /// [LockType.pin]; [question]/[answer] are required when [type] is
  /// [LockType.securityQuestion]. Implementations hash [pin]/[answer]
  /// before persisting — the plaintext never touches storage. Does NOT
  /// touch `biometric_enabled` — see [setBiometricEnabled] for that,
  /// since the two are independent settings.
  TaskEither<LockFailure, Unit> setLockType({
    required LockType type,
    String? pin,
    String? question,
    String? answer,
  });

  /// Turns the "also allow biometric" shortcut on/off, independent of
  /// [LockType]. Meaningful only when the active lock type is
  /// [LockType.pin] or [LockType.securityQuestion].
  TaskEither<LockFailure, Unit> setBiometricEnabled(bool enabled);

  /// True if the device has biometric hardware with something enrolled
  /// and the OS reports it as usable right now.
  TaskEither<LockFailure, bool> isBiometricAvailable();

  /// Runs the OS-level biometric prompt. Returns true on success, false
  /// if the user cancelled or the OS reported failure without an error.
  TaskEither<LockFailure, bool> authenticateWithBiometrics({
    required String reason,
  });

  /// Hashes [pin] and compares it against the stored PIN hash.
  TaskEither<LockFailure, Unit> verifyPin(String pin);

  /// Hashes [answer] (case-insensitively, trimmed) and compares it
  /// against the stored security-answer hash.
  TaskEither<LockFailure, Unit> verifySecurityAnswer(String answer);
}