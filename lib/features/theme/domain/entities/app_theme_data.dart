// lib/features/theme/domain/entities/app_theme_data.dart

import 'package:equatable/equatable.dart';

/// Domain entity representing a single theme — either one of the static
/// default presets, or a user-created custom theme.
///
/// Colors are stored as hex strings (e.g. `'#6750A4'`) rather than
/// Flutter's `Color` type, keeping the domain layer free of Flutter
/// framework dependencies. The presentation layer converts to/from
/// `Color` when building actual `ThemeData`.
class AppThemeData extends Equatable {
  final String id;
  final String name;

  /// True for user-created themes (stored in `custom_themes`), false
  /// for the static built-in presets.
  final bool isCustom;

  final String primaryColor;
  final String backgroundColor;
  final String accentColor;
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
    String? primaryColor,
    String? backgroundColor,
    String? accentColor,
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