// lib/features/theme/data/models/app_theme_model.dart

import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_data.dart';

/// Data model for a theme — the sqflite-facing counterpart to the domain
/// [AppThemeData] entity.
///
/// Only CUSTOM themes are persisted to the `custom_themes` table via
/// [fromMap]/[toMap] — the four bundled default themes are defined below
/// as a static const list and never touch the database. Colors are stored
/// as their 32-bit ARGB integer value (`Color.toARGB32()` /
/// `Color(argb)`), the standard way to persist a Flutter `Color` in a
/// TEXT/INTEGER sqflite column.
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

  /// Builds an [AppThemeModel] from a `custom_themes` table row.
  /// `isCustom` is always `true` for rows read from this table — only
  /// custom themes are ever persisted here.
  factory AppThemeModel.fromMap(Map<String, dynamic> map) {
    return AppThemeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isCustom: true,
      primaryColor: Color(map['primary_color'] as int),
      backgroundColor: Color(map['background_color'] as int),
      accentColor: Color(map['accent_color'] as int),
      headerImagePath: map['header_image_path'] as String?,
    );
  }

  /// Converts this model to a `Map<String, dynamic>` suitable for
  /// `Database.insert`/`Database.update` against `custom_themes`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'primary_color': primaryColor.toARGB32(),
      'background_color': backgroundColor.toARGB32(),
      'accent_color': accentColor.toARGB32(),
      'header_image_path': headerImagePath,
    };
  }

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

  /// The four bundled default themes, always available regardless of
  /// database state. Each seeds a Material 3 `ColorScheme` via
  /// `ColorScheme.fromSeed` at the point of `ThemeData` conversion (see
  /// `core/theme/theme_mapper.dart`) rather than hand-specifying every
  /// color role — `primaryColor`/`accentColor` here are seed colors, not
  /// literal UI colors.
  ///
  /// `backgroundColor`'s luminance determines light vs. dark `Brightness`
  /// in the mapper — deliberately not stored as a separate `isDark` flag,
  /// since it can be derived and that avoids the two ever disagreeing.
  static const List<AppThemeModel> defaultThemes = [
    AppThemeModel(
      id: 'default_indigo',
      name: 'Indigo',
      isCustom: false,
      primaryColor: Color(0xFF3F51B5), // Indigo — seed color
      backgroundColor: Color(0xFFFAFAFC), // near-white → light theme
      accentColor: Color(0xFFFF7043), // warm coral accent
    ),
    AppThemeModel(
      id: 'default_teal',
      name: 'Teal',
      isCustom: false,
      primaryColor: Color(0xFF00897B), // Teal — seed color
      backgroundColor: Color(0xFFF7FBFA), // near-white → light theme
      accentColor: Color(0xFFFFC107), // amber accent
    ),
    AppThemeModel(
      id: 'default_terracotta',
      name: 'Terracotta',
      isCustom: false,
      primaryColor: Color(0xFFBF5B3F), // warm terracotta — seed color
      backgroundColor: Color(0xFFFDF6F2), // warm off-white → light theme
      accentColor: Color(0xFF6D8B74), // sage green accent
    ),
    AppThemeModel(
      id: 'default_midnight',
      name: 'Midnight',
      isCustom: false,
      primaryColor: Color(0xFF9575CD), // soft violet — seed color
      backgroundColor: Color(0xFF121218), // near-black → dark theme
      accentColor: Color(0xFF4DD0E1), // cyan accent
    ),
  ];
}