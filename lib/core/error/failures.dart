// lib/core/error/failures.dart

sealed class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Something went wrong reading/writing to the local SQLite database.
final class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A database error occurred.']);
}

/// Something went wrong reading/writing local cached data (e.g. shared
/// preferences, file system) that isn't the SQLite database itself.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local storage error occurred.']);
}

/// Something went wrong performing a network request — no connection,
/// a non-2xx response, a timeout, etc. Distinct from [DatabaseFailure]
/// (local SQLite) and [CacheFailure] (local file/preferences storage),
/// since the underlying cause and the user-facing message differ.
/// Mirrors [NetworkException] in exceptions.dart, which already existed
/// but had no corresponding Failure type for repositories to emit.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'A network error occurred.']);
}

/// Input provided by the user (or another layer) failed validation before
/// it ever reached the data layer — e.g. empty theme name, invalid PIN
/// format, malformed import file.
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input provided.']);
}

/// Fallback for anything unexpected that doesn't map to a known failure
/// type. Should be rare — prefer adding a specific Failure subtype when
/// a new error case becomes common enough to handle distinctly.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

/// Device biometric or device-credential authentication couldn't run —
/// no hardware, nothing enrolled, or the platform call itself failed.
/// Mirrors [BiometricException] in exceptions.dart. Distinct from a
/// normal failed/cancelled authentication attempt, which is a `false`
/// success value rather than a Failure.
final class BiometricFailure extends Failure {
  const BiometricFailure([
    super.message = 'Biometric authentication is not available.',
  ]);
}

/// A lock-specific data error that isn't a generic database failure —
/// e.g. verifying a PIN/pattern/security answer before one has been
/// configured. Mirrors [LockException] in exceptions.dart.
final class LockFailure extends Failure {
  const LockFailure([super.message = 'App lock is not configured.']);
}