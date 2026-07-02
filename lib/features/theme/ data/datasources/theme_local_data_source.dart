// lib/features/theme/data/datasources/theme_local_data_source.dart

import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../models/app_theme_model.dart';

const String kCustomThemesTable = 'custom_themes';
const String kAppSettingsTable = 'app_settings';
const String kSelectedThemeIdKey = 'selected_theme_id';

/// Abstract local data source contract for theme persistence.
///
/// Two concerns live here, matching the two tables involved:
/// `custom_themes` (CRUD for user-created themes) and `app_settings`
/// (a simple key-value table storing which theme id is currently
/// selected — same table pattern as any other app-wide preference).
/// Throws data-layer exceptions on failure; the repository impl converts
/// these to [Failure]s.
abstract class ThemeLocalDataSource {
  Future<List<AppThemeModel>> getCustomThemes();

  Future<AppThemeModel> saveCustomTheme(AppThemeModel theme);

  Future<void> deleteCustomTheme(String id);

  /// Returns the persisted selected theme id, or `null` if none has ever
  /// been set (fresh install).
  Future<String?> getSelectedThemeId();

  Future<void> setSelectedThemeId(String id);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final Database database;

  const ThemeLocalDataSourceImpl(this.database);

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<List<AppThemeModel>> getCustomThemes() async {
    try {
      final rows = await database.query(kCustomThemesTable);
      return rows.map((row) => AppThemeModel.fromMap(row)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to fetch custom themes: $e');
    }
  }

  @override
  Future<AppThemeModel> saveCustomTheme(AppThemeModel theme) async {
    try {
      final themeWithId = theme.id.isEmpty
          ? AppThemeModel.fromEntity(theme.copyWith(id: _generateId()))
          : theme;
      await database.insert(
        kCustomThemesTable,
        themeWithId.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return themeWithId;
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to save custom theme: $e');
    }
  }

  @override
  Future<void> deleteCustomTheme(String id) async {
    try {
      final rowsAffected = await database.delete(
        kCustomThemesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rowsAffected == 0) {
        throw AppDatabaseException(message: 'Custom theme with id $id not found');
      }
    } catch (e) {
      if (e is AppDatabaseException) rethrow;
      throw AppDatabaseException(message: 'Failed to delete custom theme: $e');
    }
  }

  @override
  Future<String?> getSelectedThemeId() async {
    try {
      final rows = await database.query(
        kAppSettingsTable,
        where: 'key = ?',
        whereArgs: [kSelectedThemeIdKey],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['value'] as String?;
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to read selected theme: $e');
    }
  }

  @override
  Future<void> setSelectedThemeId(String id) async {
    try {
      await database.insert(
        kAppSettingsTable,
        {'key': kSelectedThemeIdKey, 'value': id},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to persist selected theme: $e');
    }
  }
}
