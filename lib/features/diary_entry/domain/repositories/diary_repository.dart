// lib/features/diary_entry/domain/repositories/diary_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';

/// Contract for all diary entry data access, implemented by
/// `DiaryRepositoryImpl` in the data layer.
///
/// Every method returns `Either<Failure, T>` — `Left(Failure)` on error,
/// `Right(T)` on success — so the presentation layer never has to catch
/// exceptions directly.
///
/// This contract is intentionally generic: [updateEntry] accepts a full
/// [DiaryEntry], so it covers every field-level change any future
/// milestone needs (mood, favorite, tags, background, stickers, etc.)
/// without requiring new repository methods per feature.
abstract class DiaryRepository {
  /// Creates a new diary entry.
  Future<Either<Failure, void>> createEntry(DiaryEntry entry);

  /// Returns all diary entries not marked as deleted, most recent first.
  Future<Either<Failure, List<DiaryEntry>>> getAllEntries();

  /// Returns a single entry by id, or a [Failure] if not found.
  Future<Either<Failure, DiaryEntry>> getEntryById(String id);

  /// Persists changes to an existing entry. Pass the full updated entity
  /// (typically built via `existingEntry.copyWith(...)`).
  Future<Either<Failure, void>> updateEntry(DiaryEntry entry);

  /// Permanently deletes an entry by id.
  ///
  /// Note: if a Trash/soft-delete feature is adopted later, this can be
  /// changed to set `is_deleted`/`deleted_at` instead of a hard delete —
  /// the entity already has both fields to support that without a schema
  /// change.
  Future<Either<Failure, void>> deleteEntry(String id);
}