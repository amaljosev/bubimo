// lib/features/theme/domain/entities/app_theme_data.dart

import 'package:equatable/equatable.dart';

import 'rgba_color.dart';
import 'theme_palette.dart';
import 'theme_type.dart';

/// Domain representation of a single theme — either one of the 6
/// built-in themes (defined as static data, see `built_in_themes.dart`)
/// or a user-created custom theme persisted in the `custom_themes`
/// table.
///
/// Colors are stored as [RgbaColor] value objects (not hex strings or
/// Flutter [Color]s) so the domain layer stays framework-agnostic and
/// the RGBO color picker can bind to channels directly. Conversion to a
/// Flutter `ThemeData` happens at the boundary in `theme_mapper.dart`.
///
/// Five colors are user-editable, each with a distinct, explicit role
/// (see `theme_mapper.dart` for exactly how each maps onto Flutter's
/// `ColorScheme`):
/// - [primaryColor] — main brand color: FAB, filled buttons, active
///   tab/selection indicators.
/// - [secondaryColor] — accent color: secondary actions, highlights,
///   selected-state tints (previously named `accentColor`).
/// - [surfaceColor] — cards, sheets, app bars, dialogs — content
///   surfaces that sit above [backgroundColor].
/// - [backgroundColor] — the scaffold/page background.
/// - [textColor] — primary text/icon color across the theme.
///
/// [isDark] is an explicit user choice (Light Mode / Dark Mode toggle)
/// rather than derived from background luminance — this lets the form
/// validate the user's other picks against an intent that's known up
/// front, rather than inferred after the fact.
///
/// ### Light/Dark dual palettes (custom themes only)
///
/// A custom theme can carry an independent color palette for EACH mode
/// — [lightPalette] and [darkPalette] — so switching the Dark Mode
/// toggle while editing recalls that mode's own previously-saved
/// colors instead of discarding them. [primaryColor]/[secondaryColor]/
/// etc. above always reflect whichever palette is CURRENTLY ACTIVE
/// (i.e. [isDark] ? [darkPalette] : [lightPalette]) — this keeps
/// `theme_mapper.dart`, `built_in_themes.dart`, and every other
/// existing call site unchanged, since they only ever care about "the
/// theme's current 5 colors," never about the other, inactive mode's
/// palette.
///
/// Built-in themes never populate [lightPalette]/[darkPalette] (they
/// remain `null`) — each built-in is only ever one fixed mode, so a
/// second palette would never be used.
class AppThemeData extends Equatable {
  final String id;
  final String name;
  final ThemeType type;
  final RgbaColor primaryColor;
  final RgbaColor secondaryColor;
  final RgbaColor surfaceColor;
  final RgbaColor backgroundColor;
  final RgbaColor textColor;

  /// True for a Dark Mode theme, false for Light Mode. User-selected
  /// via an explicit toggle on the Create/Edit Custom Theme screen.
  final bool isDark;

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

  /// True for the 6 built-in themes — these can't be edited or deleted.
  final bool isBuiltIn;

  /// True for exactly one built-in theme: the one "Reset to Default"
  /// applies.
  final bool isDefault;

  /// This custom theme's own saved Light Mode palette, or `null` if it
  /// has never had one saved (e.g. a brand-new theme that's always
  /// been edited in Dark Mode so far). Always `null` for built-ins.
  final ThemePalette? lightPalette;

  /// This custom theme's own saved Dark Mode palette, or `null` if it
  /// has never had one saved. Always `null` for built-ins.
  final ThemePalette? darkPalette;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textColor,
    this.isDark = false,
    required this.fontFamily,
    this.headerImagePath,
    this.isHeaderImageAsset = false,
    required this.isBuiltIn,
    this.isDefault = false,
    this.lightPalette,
    this.darkPalette,
  });

  /// The palette matching this theme's CURRENT [isDark] value — a
  /// convenience for callers (e.g. the form bloc) that already work in
  /// terms of [ThemePalette] rather than the 5 flat color fields.
  ThemePalette get activePalette => ThemePalette(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        surfaceColor: surfaceColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
      );

  AppThemeData copyWith({
    String? id,
    String? name,
    ThemeType? type,
    RgbaColor? primaryColor,
    RgbaColor? secondaryColor,
    RgbaColor? surfaceColor,
    RgbaColor? backgroundColor,
    RgbaColor? textColor,
    bool? isDark,
    String? fontFamily,
    String? headerImagePath,
    bool clearHeaderImage = false,
    bool? isHeaderImageAsset,
    bool? isBuiltIn,
    bool? isDefault,
    ThemePalette? lightPalette,
    ThemePalette? darkPalette,
  }) {
    return AppThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      isDark: isDark ?? this.isDark,
      fontFamily: fontFamily ?? this.fontFamily,
      headerImagePath:
          clearHeaderImage ? null : (headerImagePath ?? this.headerImagePath),
      isHeaderImageAsset: isHeaderImageAsset ?? this.isHeaderImageAsset,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isDefault: isDefault ?? this.isDefault,
      lightPalette: lightPalette ?? this.lightPalette,
      darkPalette: darkPalette ?? this.darkPalette,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        primaryColor,
        secondaryColor,
        surfaceColor,
        backgroundColor,
        textColor,
        isDark,
        fontFamily,
        headerImagePath,
        isHeaderImageAsset,
        isBuiltIn,
        isDefault,
        lightPalette,
        darkPalette,
      ];
}