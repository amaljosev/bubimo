// lib/features/theme/domain/entities/app_theme_data.dart

import 'package:equatable/equatable.dart';

import 'rgba_color.dart';
import 'theme_type.dart';

/// Domain representation of a single theme — either one of the 4
/// built-in themes (defined as static data, see `built_in_themes.dart`)
/// or a user-created custom theme persisted in the `custom_themes`
/// table.
///
/// Colors are stored as [RgbaColor] value objects (not hex strings or
/// Flutter [Color]s) so the domain layer stays framework-agnostic and
/// the RGBO color picker can bind to channels directly. Conversion to a
/// Flutter `ThemeData` happens at the boundary in `theme_mapper.dart`.
class AppThemeData extends Equatable {
  final String id;
  final String name;
  final ThemeType type;
  final RgbaColor primaryColor;
  final RgbaColor backgroundColor;
  final RgbaColor accentColor;

  /// Google Fonts family name, e.g. `'Poppins'`, `'Caveat'`.
  final String fontFamily;

  /// Path or asset key to the header image, when [ThemeType.supportsHeaderImage]
  /// is true and the user/preset actually set one. `null` means no header
  /// image, even if the type supports it.
  ///
  /// For built-in themes this is an asset path (`'assets/images/...'`).
  /// For custom themes this is a file path on disk (cropped image saved
  /// by `image_cropper`). [isHeaderImageAsset] disambiguates which.
  final String? headerImagePath;

  /// True when [headerImagePath] refers to a bundled Flutter asset
  /// (`Image.asset`) rather than a file on disk (`Image.file`). Always
  /// false for custom themes.
  final bool isHeaderImageAsset;

  /// True for the 4 built-in themes — these can't be edited or deleted.
  final bool isBuiltIn;

  /// True for exactly one built-in theme: the one "Reset to Default"
  /// applies.
  final bool isDefault;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.fontFamily,
    this.headerImagePath,
    this.isHeaderImageAsset = false,
    required this.isBuiltIn,
    this.isDefault = false,
  });

  AppThemeData copyWith({
    String? id,
    String? name,
    ThemeType? type,
    RgbaColor? primaryColor,
    RgbaColor? backgroundColor,
    RgbaColor? accentColor,
    String? fontFamily,
    String? headerImagePath,
    bool clearHeaderImage = false,
    bool? isHeaderImageAsset,
    bool? isBuiltIn,
    bool? isDefault,
  }) {
    return AppThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      headerImagePath:
          clearHeaderImage ? null : (headerImagePath ?? this.headerImagePath),
      isHeaderImageAsset: isHeaderImageAsset ?? this.isHeaderImageAsset,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        primaryColor,
        backgroundColor,
        accentColor,
        fontFamily,
        headerImagePath,
        isHeaderImageAsset,
        isBuiltIn,
        isDefault,
      ];
}
