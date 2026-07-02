// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
/// Repositories return `Either<Failure, T>` — never throw across the
/// data/domain boundary. Data-layer exceptions (see exceptions.dart) are
/// caught in repository impls and converted into one of these.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Wraps failures originating from local database operations (sqflite).
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

/// Wraps failures originating from local cache/shared-preferences style
/// storage (e.g. app_settings key-value reads/writes).
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Wraps failures from invalid input/domain rule violations
/// (e.g. empty title where required, invalid date range).
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Wraps failures from network calls (e.g. Supabase background packs,
/// Google Drive backup/restore) once those milestones are implemented.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Catch-all for anything unanticipated. Should be rare — prefer adding
/// a specific Failure subtype over reaching for this.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}