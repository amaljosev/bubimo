// lib/core/error/exceptions.dart

/// Base class for all data-layer exceptions.
/// Thrown by data sources (local DB, cache, network); caught in repository
/// impls and converted into a matching Failure (see failures.dart) before
/// crossing into the domain layer.
abstract class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => message;
}

/// Thrown by local data sources on sqflite read/write/insert/delete errors,
/// or when an expected row is not found.
///
/// Named `AppDatabaseException` (not `DatabaseException`) because
/// `package:sqflite_common` already exports its own `DatabaseException`
/// class with a different (positional) constructor signature. Importing
/// both into the same file causes a name collision / wrong-constructor bug.
class AppDatabaseException extends AppException {
  const AppDatabaseException({required super.message});
}

/// Thrown by local cache/key-value data sources (e.g. app_settings reads).
class CacheException extends AppException {
  const CacheException({required super.message});
}

/// Thrown by remote data sources (Supabase, Google Drive) on network or
/// API errors, once those milestones are implemented.
class NetworkException extends AppException {
  const NetworkException({required super.message});
}

/// Thrown by the app lock feature when device biometric authentication
/// (fingerprint/face) or device-credential authentication cannot run —
/// no hardware, nothing enrolled, or the underlying platform call
/// failed. Not thrown for a normal failed/cancelled attempt (that's a
/// `false` return value, not an exception) — only for setup/hardware
/// issues that prevent authentication from being attempted at all.
class BiometricException extends AppException {
  const BiometricException({required super.message});
}

/// Thrown by the app lock feature for lock-specific data errors that
/// aren't generic database failures — e.g. verifying a PIN/pattern/
/// security answer when none has been configured yet.
class LockException extends AppException {
  const LockException({required super.message});
}