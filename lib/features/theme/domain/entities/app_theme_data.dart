// lib/features/theme/domain/entities/app_theme_data.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing a single selectable theme.
///
/// Deliberately stores only three source colors (`primaryColor`,
/// `backgroundColor`, `accentColor`) rather than a full hand-authored
/// `ColorScheme` — the current Material 3 recommended approach is to seed
/// a `ColorScheme` from one or two brand colors via
/// `ColorScheme.fromSeed(...)`, which algorithmically generates the full,
/// accessible tonal palette (containers, on-colors, contrast pairs)
/// rather than requiring every role to be manually specified. The actual
/// `AppThemeData` → `ThemeData` conversion lives in
/// `core/theme/theme_mapper.dart`, kept separate from this entity so the
/// domain layer has no Flutter rendering concerns.
///
/// `isCustom` distinguishes the four built-in defaults (bundled with the
/// app, `id`s are fixed known strings, never persisted to the
/// `custom_themes` table) from user-created themes (persisted, deletable).
/// `headerImagePath` is optional — when set, it's surfaced app-wide via
/// the `BackgroundImageTheme` `ThemeExtension` (see `core/theme/`), shown
/// today in Home's `SliverAppBar`.
class AppThemeData extends Equatable {
  final String id;
  final String name;
  final bool isCustom;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final String? headerImagePath;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.isCustom,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    this.headerImagePath,
  });

  AppThemeData copyWith({
    String? id,
    String? name,
    bool? isCustom,
    Color? primaryColor,
    Color? backgroundColor,
    Color? accentColor,
    String? headerImagePath,
  }) {
    return AppThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      headerImagePath: headerImagePath ?? this.headerImagePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        isCustom,
        primaryColor,
        backgroundColor,
        accentColor,
        headerImagePath,
      ];
}