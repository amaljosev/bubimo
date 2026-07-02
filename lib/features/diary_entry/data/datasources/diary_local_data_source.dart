// lib/features/diary_entry/data/datasources/diary_local_data_source.dart

import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../models/diary_entry_model.dart';

const String kDiaryEntriesTable = 'diary_entries';

/// Abstract local data source contract for diary entries.
/// Throws data-layer exceptions (e.g. [AppDatabaseException]) on failure;
/// the repository impl is responsible for converting these to Failures.
abstract class DiaryLocalDataSource {
  Future<DiaryEntryModel> createEntry(DiaryEntryModel entry);

  Future<List<DiaryEntryModel>> getAllEntries();

  Future<DiaryEntryModel> getEntryById(String id);

  Future<DiaryEntryModel> updateEntry(DiaryEntryModel entry);

  Future<void> deleteEntry(String id);
}

class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  final Database database;

  const DiaryLocalDataSourceImpl(this.database);

  /// `id` is a TEXT primary key with no autoincrement, so it must be
  /// generated client-side before insert. Using microsecond-epoch string
  /// rather than pulling in a `uuid` dependency, since `uuid` isn't in the
  /// locked pubspec. Swap this for `Uuid().v4()` if/when that package is
  /// added.
  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<DiaryEntryModel> createEntry(DiaryEntryModel entry) async {
    try {
      final entryWithId = entry.id == null
          ? DiaryEntryModel.fromEntity(entry.copyWith(id: _generateId()))
          : entry;
      await database.insert(
        kDiaryEntriesTable,
        entryWithId.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return entryWithId;
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to create diary entry: $e');
    }
  }

  @override
  Future<List<DiaryEntryModel>> getAllEntries() async {
    try {
      final rows = await database.query(
        kDiaryEntriesTable,
        orderBy: 'created_at DESC',
      );
      return rows.map((row) => DiaryEntryModel.fromMap(row)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to fetch diary entries: $e');
    }
  }

  @override
  Future<DiaryEntryModel> getEntryById(String id) async {
    try {
      final rows = await database.query(
        kDiaryEntriesTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw AppDatabaseException(message: 'Diary entry with id $id not found');
      }
      return DiaryEntryModel.fromMap(rows.first);
    } catch (e) {
      if (e is AppDatabaseException) rethrow;
      throw AppDatabaseException(message: 'Failed to fetch diary entry: $e');
    }
  }

  @override
  Future<DiaryEntryModel> updateEntry(DiaryEntryModel entry) async {
    try {
      if (entry.id == null) {
        throw AppDatabaseException(message: 'Cannot update entry without an id');
      }
      final rowsAffected = await database.update(
        kDiaryEntriesTable,
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      if (rowsAffected == 0) {
        throw AppDatabaseException(
          message: 'Diary entry with id ${entry.id} not found',
        );
      }
      return entry;
    } catch (e) {
      if (e is AppDatabaseException) rethrow;
      throw AppDatabaseException(message: 'Failed to update diary entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      final rowsAffected = await database.delete(
        kDiaryEntriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rowsAffected == 0) {
        throw AppDatabaseException(message: 'Diary entry with id $id not found');
      }
    } catch (e) {
      if (e is AppDatabaseException) rethrow;
      throw AppDatabaseException(message: 'Failed to delete diary entry: $e');
    }
  }
}