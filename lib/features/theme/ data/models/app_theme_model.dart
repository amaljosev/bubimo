// lib/features/theme/data/models/app_theme_model.dart

import '../../../../core/database/tables/custom_themes_table.dart';
import '../../domain/entities/app_theme_data.dart';

/// Data-layer representation of [AppThemeData], responsible for
/// converting between the domain entity and raw sqflite rows in the
/// `custom_themes` table.
///
/// Also hosts the static list of built-in default theme presets — these
/// are NOT stored in the database, they're fixed app data. Only
/// user-created custom themes are persisted.
class AppThemeModel extends AppThemeData {
  const AppThemeModel({
    required super.id,
    required super.name,
    required super.isCustom,
    required super.primaryColor,
    required super.backgroundColor,
    required super.accentColor,
    super.headerImagePath,
  });

  /// Builds an [AppThemeModel] from a domain [AppThemeData], so the data
  /// layer can persist an entity constructed by the Custom Theme Screen.
  factory AppThemeModel.fromEntity(AppThemeData theme) {
    return AppThemeModel(
      id: theme.id,
      name: theme.name,
      isCustom: theme.isCustom,
      primaryColor: theme.primaryColor,
      backgroundColor: theme.backgroundColor,
      accentColor: theme.accentColor,
      headerImagePath: theme.headerImagePath,
    );
  }

  /// Builds an [AppThemeModel] from a raw `custom_themes` row. All rows
  /// in this table are user-created, so [isCustom] is always true here.
  factory AppThemeModel.fromMap(Map<String, Object?> map) {
    return AppThemeModel(
      id: map[CustomThemesTable.columnId] as String,
      name: map[CustomThemesTable.columnName] as String,
      isCustom: true,
      primaryColor: map[CustomThemesTable.columnPrimaryColor] as String,
      backgroundColor:
          map[CustomThemesTable.columnBackgroundColor] as String,
      accentColor: map[CustomThemesTable.columnAccentColor] as String,
      headerImagePath:
          map[CustomThemesTable.columnHeaderImagePath] as String?,
    );
  }

  /// Converts this model into a raw `custom_themes` row for insert/update.
  /// [createdAt] is only needed on insert — callers pass the original
  /// value back on update so it's never overwritten.
  Map<String, Object?> toMap({required String createdAt}) {
    return {
      CustomThemesTable.columnId: id,
      CustomThemesTable.columnName: name,
      CustomThemesTable.columnPrimaryColor: primaryColor,
      CustomThemesTable.columnBackgroundColor: backgroundColor,
      CustomThemesTable.columnAccentColor: accentColor,
      CustomThemesTable.columnHeaderImagePath: headerImagePath,
      CustomThemesTable.columnCreatedAt: createdAt,
    };
  }

  /// Built-in default theme presets, shown alongside custom themes on
  /// the Theme Screen. Colors are hex strings, consistent with how
  /// custom themes are stored — the presentation layer parses these
  /// into `Color` when building actual `ThemeData`.
  static const List<AppThemeModel> defaultThemes = [
    AppThemeModel(
      id: 'default_lavender',
      name: 'Lavender',
      isCustom: false,
      primaryColor: '#6750A4',
      backgroundColor: '#FFFBFE',
      accentColor: '#7D5260',
    ),
    AppThemeModel(
      id: 'default_ocean',
      name: 'Ocean',
      isCustom: false,
      primaryColor: '#006874',
      backgroundColor: '#F5FDFF',
      accentColor: '#4A6363',
    ),
    AppThemeModel(
      id: 'default_sunset',
      name: 'Sunset',
      isCustom: false,
      primaryColor: '#9C4146',
      backgroundColor: '#FFF8F6',
      accentColor: '#77574C',
    ),
    AppThemeModel(
      id: 'default_forest',
      name: 'Forest',
      isCustom: false,
      primaryColor: '#3A6A3E',
      backgroundColor: '#F7FDF2',
      accentColor: '#54634E',
    ),
    AppThemeModel(
      id: 'default_midnight',
      name: 'Midnight',
      isCustom: false,
      primaryColor: '#4B5AA8',
      backgroundColor: '#FAFBFF',
      accentColor: '#5C5D72',
    ),
  ];
}