// lib/features/diary_entry/data/datasources/diary_local_data_source.dart

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/diary_entries_table.dart';
import '../models/diary_entry_model.dart';

/// Raw sqflite access for the `diary_entries` table. No error-wrapping
/// here — exceptions propagate up to [DiaryRepositoryImpl], which is
/// responsible for converting them into `Either<Failure, T>`.
abstract class DiaryLocalDataSource {
  Future<void> insertEntry(DiaryEntryModel entry);
  Future<List<DiaryEntryModel>> getAllEntries();
  Future<DiaryEntryModel> getEntryById(String id);
  Future<void> updateEntry(DiaryEntryModel entry);
  Future<void> deleteEntry(String id);
}

class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  final AppDatabase appDatabase;

  const DiaryLocalDataSourceImpl(this.appDatabase);

  @override
  Future<void> insertEntry(DiaryEntryModel entry) async {
    final db = await appDatabase.database;
    await db.insert(
      DiaryEntriesTable.tableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<DiaryEntryModel>> getAllEntries() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      DiaryEntriesTable.tableName,
      where: '${DiaryEntriesTable.columnIsDeleted} = ?',
      whereArgs: [0],
      orderBy: '${DiaryEntriesTable.columnDate} DESC',
    );
    return rows.map(DiaryEntryModel.fromMap).toList();
  }

  @override
  Future<DiaryEntryModel> getEntryById(String id) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      DiaryEntriesTable.tableName,
      where: '${DiaryEntriesTable.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('No diary entry found with id: $id');
    }
    return DiaryEntryModel.fromMap(rows.first);
  }

  @override
  Future<void> updateEntry(DiaryEntryModel entry) async {
    final db = await appDatabase.database;
    final rowsAffected = await db.update(
      DiaryEntriesTable.tableName,
      entry.toMap(),
      where: '${DiaryEntriesTable.columnId} = ?',
      whereArgs: [entry.id],
    );
    if (rowsAffected == 0) {
      throw StateError('No diary entry found with id: ${entry.id}');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    final db = await appDatabase.database;
    final rowsAffected = await db.delete(
      DiaryEntriesTable.tableName,
      where: '${DiaryEntriesTable.columnId} = ?',
      whereArgs: [id],
    );
    if (rowsAffected == 0) {
      throw StateError('No diary entry found with id: $id');
    }
  }
}