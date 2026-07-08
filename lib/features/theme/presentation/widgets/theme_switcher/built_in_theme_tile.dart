// lib/features/theme/presentation/widgets/theme_switcher/built_in_theme_tile.dart

import 'package:flutter/material.dart';

import '../../../domain/entities/app_theme_data.dart';
import '../shared/theme_color_swatch.dart';
import '../shared/theme_font_label.dart';
import '../shared/theme_header_image.dart';
import '../shared/theme_tile_card.dart';

/// A single built-in theme row on the "App Themes" tab.
///
/// Always renders [theme.name] in [theme.fontFamily] via
/// [ThemeFontLabel] — this label's font must NEVER change when a
/// different theme becomes active elsewhere in the app, so users can
/// visually tell themes apart by their font in this list regardless of
/// what's currently applied.
///
/// Tapping applies the theme immediately (built-ins can't be edited, so
/// there's no separate "Apply" confirmation step, unlike custom
/// themes).
class BuiltInThemeTile extends StatelessWidget {
  final AppThemeData theme;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const BuiltInThemeTile({
    super.key,
    required this.theme,
    required this.isActive,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerImagePath = theme.headerImagePath;

    return ThemeTileCard(
      isActive: isActive,
      isEnabled: isEnabled,
      onTap: onTap,
      leading: headerImagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: ThemeHeaderImage.fromTheme(
                  theme,
                  errorBuilder: (_) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image_outlined, color: colorScheme.outline),
                  ),
                ),
              ),
            )
          : ThemeColorGradientBlock(
              colors: [
                theme.primaryColor.toColor(),
                theme.accentColor.toColor(),
              ],
            ),
      titleAndSubtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeFontLabel(
            theme.name,
            fontFamily: theme.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          const SizedBox(height: 4),
          ThemeFontLabel(
            theme.fontFamily,
            fontFamily: theme.fontFamily,
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      trailing: isActive
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : ThemeColorDotRow(
              colors: [
                theme.primaryColor.toColor(),
                theme.accentColor.toColor(),
              ],
            ),
    );
  }
}
